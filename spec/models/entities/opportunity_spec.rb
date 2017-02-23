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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Opportunity do
  before { login }

  it "should create a new instance given valid attributes" do
    Opportunity.create!(name: "Opportunity", stage: 'analysis')
  end

  it "should be possible to create opportunity with the same name" do
    FactoryGirl.create(:opportunity, name: "Hello", user: current_user)
    expect { FactoryGirl.create(:opportunity, name: "Hello", user: current_user) }.to_not raise_error
  end

  it "have a default stage" do
    expect(Setting).to receive(:[]).with(:opportunity_default_stage).and_return('default')
    expect(Opportunity.default_stage).to eql('default')
  end

  it "have a fallback default stage" do
    expect(Opportunity.default_stage).to eql('prospecting')
  end

  describe "Update existing opportunity" do
    before(:each) do
      @account = FactoryGirl.create(:account)
      @opportunity = FactoryGirl.create(:opportunity, account: @account)
    end

    it "should create new account if requested so" do
      expect {
        @opportunity.update_with_account_and_permissions(
        account: { name: "New account" },
        opportunity: { name: "Hello" }
      )
      }.to change(Account, :count).by(1)
      expect(Account.last.name).to eq("New account")
      expect(@opportunity.name.gsub(/#\d+ /, '')).to eq("Hello")
    end

    it "should update the account another account was selected" do
      @another_account = FactoryGirl.create(:account)
      expect {
        @opportunity.update_with_account_and_permissions(
        account: { id: @another_account.id },
        opportunity: { name: "Hello" }
      )
      }.not_to change(Account, :count)
      expect(@opportunity.account).to eq(@another_account)
      expect(@opportunity.name.gsub(/#\d+ /, '')).to eq("Hello")
    end

    it "should drop existing Account if [create new account] is blank" do
      expect {
        @opportunity.update_with_account_and_permissions(
        account: { name: "" },
        opportunity: { name: "Hello" }
      )
      }.not_to change(Account, :count)
      expect(@opportunity.account).to be_nil
      expect(@opportunity.name.gsub(/#\d+ /, '')).to eq("Hello")
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      expect {
        @opportunity.update_with_account_and_permissions(
        account: { id: "" },
        opportunity: { name: "Hello" }
      )
      }.not_to change(Account, :count)
      expect(@opportunity.account).to be_nil
      expect(@opportunity.name.gsub(/#\d+ /, '')).to eq("Hello")
    end

    it "should set the probability to 0% if opportunity has been lost" do
      opportunity = FactoryGirl.create(:opportunity, stage: "prospecting", probability: 25)
      opportunity.update_attributes(stage: 'lost')
      opportunity.reload
      expect(opportunity.probability).to eq(0)
    end

    it "should set the probablility to 100% if opportunity has been won" do
      opportunity = FactoryGirl.create(:opportunity, stage: "prospecting", probability: 65)
      opportunity.update_attributes(stage: 'won')
      opportunity.reload
      expect(opportunity.probability).to eq(100)
    end
  end

  describe "Scopes" do
    it "should find non-closed opportunities" do
      Opportunity.delete_all
      @opportunities = [
        FactoryGirl.create(:opportunity, stage: "prospecting", amount: 1),
        FactoryGirl.create(:opportunity, stage: "analysis", amount: 1),
        FactoryGirl.create(:opportunity, stage: "won",      amount: 2),
        FactoryGirl.create(:opportunity, stage: "won",      amount: 2),
        FactoryGirl.create(:opportunity, stage: "lost",     amount: 3),
        FactoryGirl.create(:opportunity, stage: "lost",     amount: 3)
      ]
      expect(Opportunity.pipeline.sum(:amount)).to eq(2)
      expect(Opportunity.won.sum(:amount)).to eq(4)
      expect(Opportunity.lost.sum(:amount)).to eq(6)
      expect(Opportunity.sum(:amount)).to eq(12)
    end

    context "unassigned" do
      let(:unassigned_opportunity) { FactoryGirl.create(:opportunity, assignee: nil) }
      let(:assigned_opportunity) { FactoryGirl.create(:opportunity, assignee: FactoryGirl.create(:user)) }

      it "includes unassigned opportunities" do
        expect(Opportunity.unassigned).to include(unassigned_opportunity)
      end

      it "does not include opportunities assigned to a user" do
        expect(Opportunity.unassigned).not_to include(assigned_opportunity)
      end
    end
  end

  describe "Attach" do
    before do
      @opportunity = FactoryGirl.create(:opportunity)
    end

    it "should return nil when attaching existing asset" do
      @task = FactoryGirl.create(:task, asset: @opportunity, user: current_user)
      @contact = FactoryGirl.create(:contact)
      @opportunity.contacts << @contact

      expect(@opportunity.attach!(@task)).to eq(nil)
      expect(@opportunity.attach!(@contact)).to eq(nil)
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = FactoryGirl.create(:task, user: current_user)
      @contact = FactoryGirl.create(:contact)

      expect(@opportunity.attach!(@task)).to eq([@task])
      expect(@opportunity.attach!(@contact)).to eq([@contact])
    end
  end

  describe "Discard" do
    before do
      @opportunity = FactoryGirl.create(:opportunity)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, asset: @opportunity, user: current_user)
      expect(@opportunity.tasks.count).to eq(1)

      @opportunity.discard!(@task)
      expect(@opportunity.reload.tasks).to eq([])
      expect(@opportunity.tasks.count).to eq(0)
    end

    it "should discard an contact" do
      @contact = FactoryGirl.create(:contact)
      @opportunity.contacts << @contact
      expect(@opportunity.contacts.count).to eq(1)

      @opportunity.discard!(@contact)
      expect(@opportunity.contacts).to eq([])
      expect(@opportunity.contacts.count).to eq(0)
    end
  end

  describe "Exportable" do
    describe "assigned opportunity" do
      let(:opportunity1) { FactoryGirl.build(:opportunity, user: FactoryGirl.create(:user), assignee: FactoryGirl.create(:user)) }
      let(:opportunity2) { FactoryGirl.build(:opportunity, user: FactoryGirl.create(:user, first_name: nil, last_name: nil), assignee: FactoryGirl.create(:user, first_name: nil, last_name: nil)) }
      it_should_behave_like("exportable") do
        let(:exported) { [opportunity1, opportunity2] }
      end
    end

    describe "unassigned opportunity" do
      let(:opportunity1) { FactoryGirl.build(:opportunity, user: FactoryGirl.create(:user), assignee: nil) }
      let(:opportunity2) { FactoryGirl.build(:opportunity, user: FactoryGirl.create(:user, first_name: nil, last_name: nil), assignee: nil) }
      it_should_behave_like("exportable") do
        let(:exported) { [opportunity1, opportunity2] }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Opportunity
  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = FactoryGirl.create(:user)
        @o1 = FactoryGirl.create(:opportunity_in_pipeline, user: @user, stage: 'prospecting')
        @o2 = FactoryGirl.create(:opportunity_in_pipeline, user: @user, assignee: FactoryGirl.create(:user), stage: 'prospecting')
        @o3 = FactoryGirl.create(:opportunity_in_pipeline, user: FactoryGirl.create(:user), assignee: @user, stage: 'prospecting')
        @o4 = FactoryGirl.create(:opportunity_in_pipeline, user: FactoryGirl.create(:user), assignee: FactoryGirl.create(:user), stage: 'prospecting')
        @o5 = FactoryGirl.create(:opportunity_in_pipeline, user: FactoryGirl.create(:user), assignee: @user, stage: 'prospecting')
        @o6 = FactoryGirl.create(:opportunity, assignee: @user, stage: 'won')
        @o7 = FactoryGirl.create(:opportunity, assignee: @user, stage: 'lost')
      end

      it "should show opportunities which have been created by the user and are unassigned" do
        expect(Opportunity.visible_on_dashboard(@user)).to include(@o1)
      end

      it "should show opportunities which are assigned to the user" do
        expect(Opportunity.visible_on_dashboard(@user)).to include(@o3, @o5)
      end

      it "should not show opportunities which are not assigned to the user" do
        expect(Opportunity.visible_on_dashboard(@user)).not_to include(@o4)
      end

      it "should not show opportunities which are created by the user but assigned" do
        expect(Opportunity.visible_on_dashboard(@user)).not_to include(@o2)
      end

      it "does not include won or lost opportunities" do
        expect(Opportunity.visible_on_dashboard(@user)).not_to include(@o6)
        expect(Opportunity.visible_on_dashboard(@user)).not_to include(@o7)
      end
    end

    context "by_closes_on" do
      let(:o1) { FactoryGirl.create(:opportunity, closes_on: 3.days.from_now) }
      let(:o2) { FactoryGirl.create(:opportunity, closes_on: 7.days.from_now) }
      let(:o3) { FactoryGirl.create(:opportunity, closes_on: 5.days.from_now) }

      it "should show opportunities ordered by closes on" do
        expect(Opportunity.by_closes_on).to eq([o1, o3, o2])
      end
    end

    context "by_amount" do
      let(:o1) { FactoryGirl.create(:opportunity, amount:  50_000) }
      let(:o2) { FactoryGirl.create(:opportunity, amount:  10_000) }
      let(:o3) { FactoryGirl.create(:opportunity, amount: 750_000) }

      it "should show opportunities ordered by amount" do
        expect(Opportunity.by_amount).to eq([o3, o1, o2])
      end
    end

    context "not lost" do
      let(:o1) { FactoryGirl.create(:opportunity, stage: 'won') }
      let(:o2) { FactoryGirl.create(:opportunity, stage: 'lost') }
      let(:o3) { FactoryGirl.create(:opportunity, stage: 'analysis') }

      it "should show opportunities which are not lost" do
        expect(Opportunity.not_lost).to include(o1, o3)
      end

      it "should not show opportunities which are lost" do
        expect(Opportunity.not_lost).not_to include(o2)
      end
    end
  end
end
