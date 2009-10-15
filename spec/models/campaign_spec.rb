# == Schema Information
# Schema version: 23
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
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Campaign do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Campaign.create!(:name => "Campaign", :user => Factory(:user))
  end
end
