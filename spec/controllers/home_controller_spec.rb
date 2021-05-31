# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
  # GET /
  #----------------------------------------------------------------------------
  describe "responding to GET /" do
    before(:each) do
      login
    end

    it "should get a list of activities" do
      activity = create(:version, item: create(:account, user: current_user))
      expect(controller).to receive(:get_activities).once.and_return([activity])
      get :index
      expect(assigns[:activities]).to eq([activity])
    end

    it "should not include views in the list of activities" do
      create(:version, item: create(:account, user: current_user), event: "view")
      expect(controller).to receive(:get_activities).once.and_return([])

      get :index
      expect(assigns[:activities]).to eq([])
    end

    it "should get a list of my tasks ordered by due_at" do
      task_1 = create(:task, name: "Your first task", bucket: "due_asap", assigned_to: current_user.id)
      task_2 = create(:task, name: "Another task for you", bucket: "specific_time", calendar: 5.days.from_now.to_s, assigned_to: current_user.id)
      task_3 = create(:task, name: "Third Task", bucket: "due_next_week", assigned_to: current_user.id)
      task_4 = create(:task, name: "i've assigned it to myself", user: current_user, calendar: 20.days.from_now.to_s, assigned_to: nil, bucket: "specific_time")

      create(:task, name: "Someone else's Task", user_id: current_user.id, bucket: "due_asap", assigned_to: create(:user).id)
      create(:task, name: "Not my task", bucket: "due_asap", assigned_to: create(:user).id)

      get :index
      expect(assigns[:my_tasks]).to eq([task_1, task_2, task_3, task_4])
    end

    it "should not display completed tasks" do
      my_task = create(:task, user_id: current_user.id, name: "Your first task", bucket: "due_asap", assigned_to: current_user.id)
      create(:task, user_id: current_user.id, name: "Completed task", bucket: "due_asap", completed_at: 1.days.ago, completed_by: current_user.id, assigned_to: current_user.id)

      get :index

      expect(assigns[:my_tasks]).to eq([my_task])
    end

    it "should get a list of my opportunities ordered by closes_on" do
      opportunity_1 = create(:opportunity, name: "Your first opportunity", closes_on: 15.days.from_now, assigned_to: current_user.id, stage: 'proposal')
      opportunity_2 = create(:opportunity, name: "Another opportunity for you", closes_on: 10.days.from_now, assigned_to: current_user.id, stage: 'proposal')
      opportunity_3 = create(:opportunity, name: "Third Opportunity", closes_on: 5.days.from_now, assigned_to: current_user.id, stage: 'proposal')
      opportunity_4 = create(:opportunity, name: "Fourth Opportunity", closes_on: 50.days.from_now, assigned_to: nil, user_id: current_user.id, stage: 'proposal')

      create(:opportunity_in_pipeline, name: "Someone else's Opportunity", assigned_to: create(:user).id, stage: 'proposal')
      create(:opportunity_in_pipeline, name: "Not my opportunity", assigned_to: create(:user).id, stage: 'proposal')

      get :index
      expect(assigns[:my_opportunities]).to eq([opportunity_3, opportunity_2, opportunity_1, opportunity_4])
    end

    it "should get a list of my accounts ordered by name" do
      account_1 = create(:account, name: "Anderson", assigned_to: current_user.id)
      account_2 = create(:account, name: "Wilson", assigned_to: current_user.id)
      account_3 = create(:account, name: "Triple", assigned_to: current_user.id)
      account_4 = create(:account, name: "Double", assigned_to: nil, user_id: current_user.id)

      create(:account, name: "Someone else's Account", assigned_to: create(:user).id)
      create(:account, name: "Not my account", assigned_to: create(:user).id)

      get :index
      expect(assigns[:my_accounts]).to eq([account_1, account_4, account_3, account_2])
    end
  end

  # GET /home/options                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    before(:each) do
      login
    end

    it "should assign instance variables for user preferences" do
      @asset = create(:preference, user: current_user, name: "activity_asset", value: Base64.encode64("tasks".to_json))
      @user = create(:preference, user: current_user, name: "activity_user", value: Base64.encode64("Billy Bones".to_json))
      @duration = create(:preference, user: current_user, name: "activity_duration", value: Base64.encode64("two days".to_json))

      get :options, xhr: true
      expect(assigns[:asset]).to eq("tasks")
      expect(assigns[:user]).to eq("Billy Bones")
      expect(assigns[:duration]).to eq("two days")
      expect(assigns[:all_users]).to eq(User.order(:first_name, :last_name).to_a)
    end

    it "should not assign instance variables when hiding options" do
      get :options, params: { cancel: "true" }, xhr: true
      expect(assigns[:asset]).to eq(nil)
      expect(assigns[:user]).to eq(nil)
      expect(assigns[:duration]).to eq(nil)
      expect(assigns[:all_users]).to eq(nil)
    end
  end

  # GET /home/redraw                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET redraw" do
    before(:each) do
      login
    end

    it "should save user selected options" do
      get :redraw, params: { asset: "tasks", user: "Billy Bones", duration: "two days" }, xhr: true
      expect(current_user.pref[:activity_asset]).to eq("tasks")
      expect(current_user.pref[:activity_user]).to eq("Billy Bones")
      expect(current_user.pref[:activity_duration]).to eq("two days")
    end

    it "should get a list of activities" do
      @activity = create(:version, item: create(:account, user: current_user))
      expect(controller).to receive(:get_activities).once.and_return([@activity])

      get :index
      expect(assigns[:activities]).to eq([@activity])
    end
  end

  # GET /home/toggle                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET toggle" do
    before(:each) do
      login
    end

    it "should toggle expand/collapse state of form section in the session (delete existing session key)" do
      session[:toggle_states] = { hello: "world" }
      get :toggle, params: { id: "hello" }, xhr: true
      expect(session[:toggle_states].keys).not_to include(:hello)
    end

    it "should toggle expand/collapse state of form section in the session (save new session key)" do
      session[:toggle_states] = {}
      get :toggle, params: { id: "hello" }, xhr: true
      expect(session[:toggle_states][:hello]).to eq(true)
    end
  end

  describe "activity_user" do
    before(:each) do
      @user = double(User, id: 1, is_a?: true)
      @cur_user = double(User)
    end

    it "should find a user by email" do
      allow(@cur_user).to receive(:pref).and_return(activity_user: 'billy@example.com')
      allow(controller).to receive(:current_user).and_return(@cur_user)
      expect(User).to receive(:where).with(email: 'billy@example.com').and_return([@user])
      expect(controller.send(:activity_user)).to eq(1)
    end

    it "should find a user by first name or last name" do
      allow(@cur_user).to receive(:pref).and_return(activity_user: 'Billy')
      allow(controller).to receive(:current_user).and_return(@cur_user)
      expect(User).to receive(:where).with(first_name: 'Billy').and_return([@user])
      expect(User).to receive(:where).with(last_name: 'Billy').and_return([@user])
      expect(controller.send(:activity_user)).to eq(1)
    end

    it "should find a user by first name and last name" do
      allow(@cur_user).to receive(:pref).and_return(activity_user: 'Billy Elliot')
      allow(controller).to receive(:current_user).and_return(@cur_user)
      expect(User).to receive(:where).with(first_name: 'Billy', last_name: "Elliot").and_return([@user])
      expect(User).to receive(:where).with(first_name: 'Elliot', last_name: "Billy").and_return([@user])
      expect(controller.send(:activity_user)).to eq(1)
    end

    it "should return nil when 'all_users' is specified" do
      allow(@cur_user).to receive(:pref).and_return(activity_user: 'all_users')
      allow(controller).to receive(:current_user).and_return(@cur_user)
      expect(User).not_to receive(:where)
      expect(controller.send(:activity_user)).to eq(nil)
    end
  end

  describe "timeline" do
    before(:each) do
      login
    end

    it "should collapse all comments and emails on a specific contact" do
      comment = double(Comment)
      expect(Comment).to receive(:find).with("1").and_return(comment)
      expect(comment).to receive(:update_attribute).with(:state, 'Collapsed')
      get :timeline, params: { type: "comment", id: "1", state: "Collapsed" }, xhr: true
    end

    it "should expand all comments and emails on a specific contact" do
      comment = double(Comment)
      expect(Comment).to receive(:find).with("1").and_return(comment)
      expect(comment).to receive(:update_attribute).with(:state, 'Expanded')
      get :timeline, params: { type: "comment", id: "1", state: "Expanded" }, xhr: true
    end

    it "should not do anything when state neither Expanded nor Collapsed" do
      expect(Comment).not_to receive(:find).with("1")
      get :timeline, params: { type: "comment", id: "1", state: "Explode" }, xhr: true
    end

    it "should collapse all comments and emails on Contact" do
      where_stub = double
      expect(where_stub).to receive(:update_all).with(state: "Collapsed")
      expect(Comment).to receive(:where).and_return(where_stub)
      get :timeline, params: { id: "1,2,3,4+", state: "Collapsed" }, xhr: true
    end

    it "should not allow an arbitary state (sanitizes input)" do
      where_stub = double
      expect(where_stub).to receive(:update_all).with(state: "Expanded")
      expect(Comment).to receive(:where).and_return(where_stub)
      get :timeline, params: { id: "1,2,3,4+", state: "Expanded" }, xhr: true
    end

    it "should not update an arbitary model (sanitizes input)" do
      where_stub = double
      expect(where_stub).to receive(:update_all).with(state: "Expanded")
      expect(Comment).to receive(:where).and_return(where_stub)
      get :timeline, params: { id: "1,2,3,4+", state: "Expanded" }, xhr: true
    end
  end
end
