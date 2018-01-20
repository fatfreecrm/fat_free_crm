# frozen_string_literal: true

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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Campaign do
  it "should create a new instance given valid attributes" do
    Campaign.create!(name: "Campaign")
  end

  describe "Attach" do
    before do
      @campaign = create(:campaign)
    end

    it "should return nil when attaching existing asset" do
      expect(@campaign.attach!(create(:task, asset: @campaign))).to eq(nil)
      expect(@campaign.attach!(create(:lead, campaign: @campaign))).to eq(nil)
      expect(@campaign.attach!(create(:opportunity, campaign: @campaign))).to eq(nil)
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = create(:task)
      @lead = create(:lead)
      @opportunity = create(:opportunity)

      expect(@campaign.attach!(@task)).to eq([@task])
      expect(@campaign.attach!(@lead)).to eq([@lead])
      expect(@campaign.attach!(@opportunity)).to eq([@opportunity])
    end

    it "should increment leads count when attaching a new lead" do
      @leads_count = @campaign.leads_count

      @campaign.attach!(create(:lead))
      expect(@campaign.reload.leads_count).to eq(@leads_count + 1)
    end

    it "should increment opportunities count when attaching new opportunity" do
      @opportunities_count = @campaign.opportunities_count
      @opportunity = create(:opportunity)
      @campaign.attach!(@opportunity)
      expect(@campaign.reload.opportunities_count).to eq(@opportunities_count + 1)
    end
  end

  describe "Detach" do
    before do
      @campaign = create(:campaign, leads_count: 42, opportunities_count: 42)
    end

    it "should discard a task" do
      @task = create(:task, asset: @campaign)
      expect(@campaign.tasks.count).to eq(1)

      @campaign.discard!(@task)
      expect(@campaign.reload.tasks).to eq([])
      expect(@campaign.tasks.count).to eq(0)
    end

    it "should discard a lead" do
      @lead = create(:lead, campaign: @campaign)
      expect(@campaign.reload.leads_count).to eq(43)

      @campaign.discard!(@lead)
      expect(@campaign.leads).to eq([])
      expect(@campaign.reload.leads_count).to eq(42)
    end

    it "should discard an opportunity" do
      @opportunity = create(:opportunity, campaign: @campaign)
      expect(@campaign.reload.opportunities_count).to eq(43)

      @campaign.discard!(@opportunity)
      expect(@campaign.opportunities).to eq([])
      expect(@campaign.reload.opportunities_count).to eq(42)
    end
  end

  describe "Exportable" do
    describe "assigned campaign" do
      let(:campaign1) { build(:campaign, user: create(:user, first_name: "John", last_name: "Smith"), assignee: create(:user)) }
      let(:campaign2) { build(:campaign, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil)) }
      it_should_behave_like("exportable") do
        let(:exported) { [campaign1, campaign2] }
      end
    end

    describe "unassigned campaign" do
      let(:campaign1) { build(:campaign, user: create(:user), assignee: nil) }
      let(:campaign2) { build(:campaign, user: create(:user, first_name: nil, last_name: nil), assignee: nil) }
      it_should_behave_like("exportable") do
        let(:exported) { [campaign1, campaign2] }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Campaign
  end
end
