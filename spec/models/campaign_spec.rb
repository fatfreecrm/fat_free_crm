# == Schema Information
# Schema version: 11
#
# Table name: campaigns
#
#  id                :integer(4)      not null, primary key
#  uuid              :string(36)
#  user_id           :integer(4)
#  name              :string(64)      default(""), not null
#  access            :string(8)       default("Private")
#  status            :string(64)
#  budget            :decimal(12, 2)
#  target_leads      :integer(4)
#  target_conversion :float
#  target_revenue    :decimal(12, 2)
#  actual_leads      :integer(4)
#  actual_conversion :float
#  actual_revenue    :decimal(12, 2)
#  starts_on         :date
#  ends_on           :date
#  objectives        :text
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Campaign do
  before(:each) do
    @valid_attributes = {
      :name => "RSpec campaign"
    }
  end

  it "should create a new instance given valid attributes" do
    Campaign.create!(@valid_attributes)
  end
end
