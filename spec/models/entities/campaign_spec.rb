# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: campaigns
#
#  id                  :integer         not null, primary key
#  user_id             :integer
#  assigned_to         :integer
#  name                :string(64)      default(""), not null
#  access              :string(8)       default("Public")
#  status              :string(64)
#  budget              :decimal(12, 2)
#  target_leads        :integer
#  target_conversion   :float
#  target_revenue      :decimal(12, 2)
#  leads_count         :integer
#  opportunities_count :integer
#  revenue             :decimal(12, 2)
#  starts_on           :date
#  ends_on             :date
#  objectives          :text
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  background_info     :string(255)
#

require 'spec_helper'

describe Campaign do

  let!(:current_user) { create :user }

  it "should create a new instance given valid attributes" do
    Campaign.create!(name: "Campaign", user: create(:user))
  end

  describe "Attach" do
    before do
      @campaign = create(:campaign)
    end

    it "should return nil when attaching existing asset" do
      @task = create(:task, asset: @campaign, user: current_user)
      @lead = create(:lead, campaign: @campaign)
      @opportunity = create(:opportunity, campaign: @campaign)

      @campaign.attach!(@task).should == nil
      @campaign.attach!(@lead).should == nil
      @campaign.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = create(:task, user: current_user)
      @lead = create(:lead)
      @opportunity = create(:opportunity)

      @campaign.attach!(@task).should == [ @task ]
      @campaign.attach!(@lead).should == [ @lead ]
      @campaign.attach!(@opportunity).should == [ @opportunity ]
    end

    it "should increment leads count when attaching a new lead" do
      @leads_count = @campaign.leads_count
      @lead = create(:lead)

      @campaign.attach!(@lead)
      @campaign.reload.leads_count.should == @leads_count + 1
    end

    it "should increment opportunities count when attaching new opportunity" do
      @opportunities_count = @campaign.opportunities_count
      @opportunity = create(:opportunity)
      @campaign.attach!(@opportunity)
      @campaign.reload.opportunities_count.should == @opportunities_count + 1
    end
  end

  describe "Detach" do
    before do
      @campaign = create(:campaign, leads_count: 42, opportunities_count: 42)
    end

    it "should discard a task" do
      @task = create(:task, asset: @campaign, user: current_user)
      @campaign.tasks.count.should == 1

      @campaign.discard!(@task)
      @campaign.reload.tasks.should == []
      @campaign.tasks.count.should == 0
    end

    it "should discard a lead" do
      @lead = create(:lead, campaign: @campaign)
      @campaign.reload.leads_count.should == 43

      @campaign.discard!(@lead)
      @campaign.leads.should == []
      @campaign.reload.leads_count.should == 42
    end

    it "should discard an opportunity" do
      @opportunity = create(:opportunity, campaign: @campaign)
      @campaign.reload.opportunities_count.should == 43

      @campaign.discard!(@opportunity)
      @campaign.opportunities.should == []
      @campaign.reload.opportunities_count.should == 42
    end
  end

  describe "Exportable" do
    describe "assigned campaign" do
      before do
        Campaign.delete_all
        create(:campaign, user: create(:user, first_name: "John", last_name: "Smith"), assignee: create(:user))
        create(:campaign, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Campaign.all }
      end
    end

    describe "unassigned campaign" do
      before do
        Campaign.delete_all
        create(:campaign, user: create(:user), assignee: nil)
        create(:campaign, user: create(:user, first_name: nil, last_name: nil), assignee: nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Campaign.all }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Campaign
  end
end
