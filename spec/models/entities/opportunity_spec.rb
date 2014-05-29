# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: opportunities
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  source          :string(32)
#  stage           :string(32)
#  probability     :integer
#  amount          :decimal(12, 2)
#  discount        :decimal(12, 2)
#  closes_on       :date
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

require 'spec_helper'

describe Opportunity do

  let!(:current_user) { create :user }

  it "should create a new instance given valid attributes" do
    Opportunity.create!(name: "Opportunity", stage: 'analysis')
  end

  it "should be possible to create opportunity with the same name" do
    first  = create(:opportunity, name: "Hello", user: current_user)
    expect { create(:opportunity, name: "Hello", user: current_user) }.to_not raise_error()
  end

  it "have a default stage" do
    Setting.should_receive(:[]).with(:opportunity_default_stage).and_return('default')
    Opportunity.default_stage.should eql('default')
  end

  it "have a fallback default stage" do
    Opportunity.default_stage.should eql('prospecting')
  end

  describe "Update existing opportunity" do
    before(:each) do
      @account = create(:account)
      @opportunity = create(:opportunity, account: @account)
    end

    it "should create new account if requested so" do
      lambda { @opportunity.update_with_account_and_permissions({
        account: { name: "New account" },
        opportunity: { name: "Hello" }
      })}.should change(Account, :count).by(1)
      Account.last.name.should == "New account"
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should update the account another account was selected" do
      @another_account = create(:account)
      lambda { @opportunity.update_with_account_and_permissions({
        account: { id: @another_account.id },
        opportunity: { name: "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should == @another_account
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should drop existing Account if [create new account] is blank" do
      lambda { @opportunity.update_with_account_and_permissions({
        account: { name: "" },
        opportunity: { name: "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should be_nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      lambda { @opportunity.update_with_account_and_permissions({
        account: { id: "" },
        opportunity: { name: "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should be_nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should set the probability to 0% if opportunity has been lost" do
      opportunity = create(:opportunity, stage: "prospecting", probability: 25)
      opportunity.update_attributes(stage: 'lost')
      opportunity.reload
      opportunity.probability.should == 0
    end

    it "should set the probablility to 100% if opportunity has been won" do
      opportunity = create(:opportunity, stage: "prospecting", probability: 65)
      opportunity.update_attributes(stage: 'won')
      opportunity.reload
      opportunity.probability.should == 100
    end
  end

  describe "Scopes" do
    it "should find non-closed opportunities" do
      Opportunity.delete_all
      @opportunities = [
        create(:opportunity, stage: "prospecting", amount: 1),
        create(:opportunity, stage: "analysis", amount: 1),
        create(:opportunity, stage: "won",      amount: 2),
        create(:opportunity, stage: "won",      amount: 2),
        create(:opportunity, stage: "lost",     amount: 3),
        create(:opportunity, stage: "lost",     amount: 3)
      ]
      Opportunity.pipeline.sum(:amount).should ==  2
      Opportunity.won.sum(:amount).should      ==  4
      Opportunity.lost.sum(:amount).should     ==  6
      Opportunity.sum(:amount).should          == 12
    end

    context "unassigned" do
      let(:unassigned_opportunity){ create(:opportunity, assignee: nil)}
      let(:assigned_opportunity){ create(:opportunity, assignee: create(:user))}

      it "includes unassigned opportunities" do
        Opportunity.unassigned.should include(unassigned_opportunity)
      end

      it "does not include opportunities assigned to a user" do
        Opportunity.unassigned.should_not include(assigned_opportunity)
      end
    end
  end

  describe "Attach" do
    before do
      @opportunity = create(:opportunity)
    end

    it "should return nil when attaching existing asset" do
      @task = create(:task, asset: @opportunity, user: current_user)
      @contact = create(:contact)
      @opportunity.contacts << @contact

      @opportunity.attach!(@task).should == nil
      @opportunity.attach!(@contact).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = create(:task, user: current_user)
      @contact = create(:contact)

      @opportunity.attach!(@task).should == [ @task ]
      @opportunity.attach!(@contact).should == [ @contact ]
    end
  end

  describe "Discard" do
    before do
      @opportunity = create(:opportunity)
    end

    it "should discard a task" do
      @task = create(:task, asset: @opportunity, user: current_user)
      @opportunity.tasks.count.should == 1

      @opportunity.discard!(@task)
      @opportunity.reload.tasks.should == []
      @opportunity.tasks.count.should == 0
    end

    it "should discard an contact" do
      @contact = create(:contact)
      @opportunity.contacts << @contact
      @opportunity.contacts.count.should == 1

      @opportunity.discard!(@contact)
      @opportunity.contacts.should == []
      @opportunity.contacts.count.should == 0
    end
  end

  describe "Exportable" do
    describe "assigned opportunity" do
      before do
        Opportunity.delete_all
        create(:opportunity, user: create(:user), assignee: create(:user))
        create(:opportunity, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Opportunity.all }
      end
    end

    describe "unassigned opportunity" do
      before do
        Opportunity.delete_all
        create(:opportunity, user: create(:user), assignee: nil)
        create(:opportunity, user: create(:user, first_name: nil, last_name: nil), assignee: nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Opportunity.all }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Opportunity
  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = create(:user)
        @o1 = create(:opportunity_in_pipeline, user: @user, stage: 'prospecting')
        @o2 = create(:opportunity_in_pipeline, user: @user, assignee: create(:user), stage: 'prospecting')
        @o3 = create(:opportunity_in_pipeline, user: create(:user), assignee: @user, stage: 'prospecting')
        @o4 = create(:opportunity_in_pipeline, user: create(:user), assignee: create(:user), stage: 'prospecting')
        @o5 = create(:opportunity_in_pipeline, user: create(:user), assignee: @user, stage: 'prospecting')
        @o6 = create(:opportunity, assignee: @user, stage: 'won')
        @o7 = create(:opportunity, assignee: @user, stage: 'lost')
      end

      it "should show opportunities which have been created by the user and are unassigned" do
        Opportunity.visible_on_dashboard(@user).should include(@o1)
      end

      it "should show opportunities which are assigned to the user" do
        Opportunity.visible_on_dashboard(@user).should include(@o3, @o5)
      end

      it "should not show opportunities which are not assigned to the user" do
        Opportunity.visible_on_dashboard(@user).should_not include(@o4)
      end

      it "should not show opportunities which are created by the user but assigned" do
        Opportunity.visible_on_dashboard(@user).should_not include(@o2)
      end

      it "does not include won or lost opportunities" do
        Opportunity.visible_on_dashboard(@user).should_not include(@o6)
        Opportunity.visible_on_dashboard(@user).should_not include(@o7)
      end
    end

    context "by_closes_on" do
      let(:o1) { create(:opportunity, closes_on: 3.days.from_now) }
      let(:o2) { create(:opportunity, closes_on: 7.days.from_now) }
      let(:o3) { create(:opportunity, closes_on: 5.days.from_now) }

      it "should show opportunities ordered by closes on" do
        Opportunity.by_closes_on.should == [o1, o3, o2]
      end
    end

    context "by_amount" do
      let(:o1) { create(:opportunity, amount:  50000) }
      let(:o2) { create(:opportunity, amount:  10000) }
      let(:o3) { create(:opportunity, amount: 750000) }

      it "should show opportunities ordered by amount" do
        Opportunity.by_amount.should == [o3, o1, o2]
      end
    end

    context "not lost" do
      let(:o1) { create(:opportunity, stage: 'won') }
      let(:o2) { create(:opportunity, stage: 'lost') }
      let(:o3) { create(:opportunity, stage: 'analysis') }

      it "should show opportunities which are not lost" do
        Opportunity.not_lost.should include(o1, o3)
      end

      it "should not show opportunities which are lost" do
        Opportunity.not_lost.should_not include(o2)
      end
    end
  end
end
