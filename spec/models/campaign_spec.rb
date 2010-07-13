# == Schema Information
# Schema version: 27
#
# Table name: campaigns
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  assigned_to         :integer(4)
#  name                :string(64)      default(""), not null
#  access              :string(8)       default("Private")
#  status              :string(64)
#  budget              :decimal(12, 2)
#  target_leads        :integer(4)
#  target_conversion   :float
#  target_revenue      :decimal(12, 2)
#  leads_count         :integer(4)
#  opportunities_count :integer(4)
#  revenue             :decimal(12, 2)
#  starts_on           :date
#  ends_on             :date
#  objectives          :text
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  background_info     :string(255)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Campaign do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Campaign.create!(:name => "Campaign", :user => Factory(:user))
  end

  describe "Detach" do
    before do
      @campaign = Factory(:campaign, :leads_count => 42, :opportunities_count => 42)
    end

    it "should discard a task" do
      @task = Factory(:task, :asset => @campaign, :user => @current_user)
      @campaign.tasks.count.should == 1

      @campaign.discard!(@task)
      @campaign.reload.tasks.should == []
      @campaign.tasks.count.should == 0
    end

    it "should discard a lead" do
      @lead = Factory(:lead, :campaign => @campaign)
      @campaign.reload.leads_count.should == 43

      @campaign.discard!(@lead)
      @campaign.leads.should == []
      @campaign.reload.leads_count.should == 42
    end

    it "should discard an opportunity" do
      @opportunity = Factory(:opportunity, :campaign => @campaign)
      @campaign.reload.opportunities_count.should == 43
    
      @campaign.discard!(@opportunity)
      @campaign.opportunities.should == []
      @campaign.reload.opportunities_count.should == 42
    end
  end
end
