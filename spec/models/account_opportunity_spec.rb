# == Schema Information
# Schema version: 27
#
# Table name: account_opportunities
#
#  id             :integer(4)      not null, primary key
#  account_id     :integer(4)
#  opportunity_id :integer(4)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountOpportunity do
  before(:each) do
    @valid_attributes = {
      :account => mock_model(Account),
      :opportunity => mock_model(Opportunity)
    }
  end

  it "should create a new instance given valid attributes" do
    AccountOpportunity.create!(@valid_attributes)
  end
end
