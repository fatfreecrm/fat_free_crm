# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe HomeController do

  # GET /
  #----------------------------------------------------------------------------
  describe "responding to GET /" do
    before(:each) do
      require_user
    end

    it "should get a list of activities" do
      activity = create(:version, item: create(:account, user: current_user))
      controller.should_receive(:get_activities).once.and_return([ activity ])
      get :index
      assigns[:activities].should == [ activity ]
    end

    it "should not include views in the list of activities" do
      activity = create(:version, item: create(:account, user: @current_user),
        event: "view")
      controller.should_receive(:get_activities).once.and_return([])

      get :index
      assigns[:activities].should == []
    end

    it "should get a list of my tasks ordered by due_at" do
      task_1 = create(:task, name: "Your first task", bucket: "due_asap", assigned_to: current_user.id)
      task_2 = create(:task, name: "Another task for you", bucket: "specific_time", calendar: 5.days.from_now.to_s, assigned_to: current_user.id)
      task_3 = create(:task, name: "Third Task", bucket: "due_next_week", assigned_to: current_user.id)
      task_4 = create(:task, name: "i've assigned it to myself", user: current_user, calendar: 20.days.from_now.to_s, assigned_to: nil, bucket: "specific_time")

      create(:task, name: "Someone else's Task", user_id: current_user.id, bucket: "due_asap", assigned_to: create(:user).id)
      create(:task, name: "Not my task", bucket: "due_asap", assigned_to: create(:user).id)

      get :index
      assigns[:my_tasks].should == [task_1, task_2, task_3, task_4]
    end

    it "should not display completed tasks" do
      task_1 = create(:task, user_id: current_user.id, name: "Your first task", bucket: "due_asap", assigned_to: current_user.id)
      task_2 = create(:task, user_id: current_user.id, name: "Completed task", bucket: "due_asap", completed_at: 1.days.ago, completed_by: current_user.id, assigned_to: current_user.id)

      get :index
      assigns[:my_tasks].should == [task_1]
    end

    it "should get a list of my opportunities ordered by closes_on" do
      opportunity_1 = create(:opportunity, name: "Your first opportunity", closes_on: 15.days.from_now, assigned_to: current_user.id, stage: 'proposal')
      opportunity_2 = create(:opportunity, name: "Another opportunity for you", closes_on: 10.days.from_now, assigned_to: current_user.id, stage: 'proposal')
      opportunity_3 = create(:opportunity, name: "Third Opportunity", closes_on: 5.days.from_now, assigned_to: current_user.id, stage: 'proposal')
      opportunity_4 = create(:opportunity, name: "Fourth Opportunity", closes_on: 50.days.from_now, assigned_to: nil, user_id: current_user.id, stage: 'proposal')

      create(:opportunity_in_pipeline, name: "Someone else's Opportunity", assigned_to: create(:user).id, stage: 'proposal')
      create(:opportunity_in_pipeline, name: "Not my opportunity", assigned_to: create(:user).id, stage: 'proposal')

      get :index
      assigns[:my_opportunities].should == [opportunity_3, opportunity_2, opportunity_1, opportunity_4]
    end

    it "should get a list of my accounts ordered by name" do
      account_1 = create(:account, name: "Anderson", assigned_to: current_user.id)
      account_2 = create(:account, name: "Wilson", assigned_to: current_user.id)
      account_3 = create(:account, name: "Triple", assigned_to: current_user.id)
      account_4 = create(:account, name: "Double", assigned_to: nil, user_id: current_user.id)

      create(:account, name: "Someone else's Account", assigned_to: create(:user).id)
      create(:account, name: "Not my account", assigned_to: create(:user).id)

      get :index
      assigns[:my_accounts].should == [account_1, account_4, account_3, account_2]
    end

  end

  # GET /home/options                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    before(:each) do
      require_user
    end

    it "should assign instance variables for user preferences" do
      @asset = create(:preference, user: current_user, name: "activity_asset", value: Base64.encode64(Marshal.dump("tasks")))
      @user = create(:preference, user: current_user, name: "activity_user", value: Base64.encode64(Marshal.dump("Billy Bones")))
      @duration = create(:preference, user: current_user, name: "activity_duration", value: Base64.encode64(Marshal.dump("two days")))

      xhr :get, :options
      assigns[:asset].should == "tasks"
      assigns[:user].should == "Billy Bones"
      assigns[:duration].should == "two days"
      assigns[:all_users].should == User.order("first_name, last_name").all
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, cancel: "true"
      assigns[:asset].should == nil
      assigns[:user].should == nil
      assigns[:duration].should == nil
      assigns[:all_users].should == nil
    end
  end

  # GET /home/redraw                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET redraw" do
    before(:each) do
      require_user
    end

    it "should save user selected options" do
      xhr :get, :redraw, asset: "tasks", user: "Billy Bones", duration: "two days"
      current_user.pref[:activity_asset].should == "tasks"
      current_user.pref[:activity_user].should == "Billy Bones"
      current_user.pref[:activity_duration].should == "two days"
    end

    it "should get a list of activities" do
      @activity = create(:version, item: create(:account, user: current_user))
      controller.should_receive(:get_activities).once.and_return([ @activity ])

      get :index
      assigns[:activities].should == [ @activity ]
    end
  end

  # GET /home/toggle                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET toggle" do
    it "should toggle expand/collapse state of form section in the session (delete existing session key)" do
      session[:hello] = "world"

      xhr :get, :toggle, id: "hello"
      session.keys.should_not include(:hello)
    end

    it "should toggle expand/collapse state of form section in the session (save new session key)" do
      session.delete(:hello)

      xhr :get, :toggle, id: "hello"
      session[:hello].should == true
    end
  end

  describe "activity_user" do

    before(:each) do
      @user = double(User, id: 1, is_a?: true)
      @cur_user = double(User)
    end

    it "should find a user by email" do
      @cur_user.stub(:pref).and_return(activity_user: 'billy@example.com')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_receive(:where).with(email: 'billy@example.com').and_return([@user])
      controller.send(:activity_user).should == 1
    end

    it "should find a user by first name or last name" do
      @cur_user.stub(:pref).and_return(activity_user: 'Billy')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_receive(:where).with(first_name: 'Billy').and_return([@user])
      User.should_receive(:where).with(last_name: 'Billy').and_return([@user])
      controller.send(:activity_user).should == 1
    end

    it "should find a user by first name and last name" do
      @cur_user.stub(:pref).and_return(activity_user: 'Billy Elliot')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_receive(:where).with(first_name: 'Billy', last_name: "Elliot").and_return([@user])
      User.should_receive(:where).with(first_name: 'Elliot', last_name: "Billy").and_return([@user])
      controller.send(:activity_user).should == 1
    end

    it "should return nil when 'all_users' is specified" do
      @cur_user.stub(:pref).and_return(activity_user: 'all_users')
      controller.instance_variable_set(:@current_user, @cur_user)
      User.should_not_receive(:where)
      controller.send(:activity_user).should == nil
    end

  end

  describe "timeline" do

    before(:each) do
      require_user
    end

    it "should collapse all comments and emails on a specific contact" do
      comment = double(Comment)
      Comment.should_receive(:find).with("1").and_return(comment)
      comment.should_receive(:update_attribute).with(:state, 'Collapsed')
      xhr :get, :timeline, type: "comment", id: "1", state: "Collapsed"
    end

    it "should expand all comments and emails on a specific contact" do
      comment = double(Comment)
      Comment.should_receive(:find).with("1").and_return(comment)
      comment.should_receive(:update_attribute).with(:state, 'Expanded')
      xhr :get, :timeline, type: "comment", id: "1", state: "Expanded"
    end

    it "should not do anything when state neither Expanded nor Collapsed" do
      comment = double(Comment)
      Comment.should_not_receive(:find).with("1")
      xhr :get, :timeline, type: "comment", id: "1", state: "Explode"
    end

    it "should collapse all comments and emails on Contact" do
      where_stub = double
      where_stub.should_receive(:update_all).with(state: "Collapsed")
      Comment.should_receive(:where).and_return(where_stub)
      xhr :get, :timeline, id: "1,2,3,4+", state: "Collapsed"
    end

    it "should not allow an arbitary state (sanitizes input)" do
      where_stub = double
      where_stub.should_receive(:update_all).with(state: "Expanded")
      Comment.should_receive(:where).and_return(where_stub)
      xhr :get, :timeline, id: "1,2,3,4+", state: "Expanded"
    end

    it "should not update an arbitary model (sanitizes input)" do
      where_stub = double
      where_stub.should_receive(:update_all).with(state: "Expanded")
      Comment.should_receive(:where).and_return(where_stub)
      xhr :get, :timeline, id: "1,2,3,4+", state: "Expanded"
    end
  end
end
