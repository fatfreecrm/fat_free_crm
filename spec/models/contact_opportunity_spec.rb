# == Schema Information
# Schema version: 27
#
# Table name: contact_opportunities
#
#  id             :integer(4)      not null, primary key
#  contact_id     :integer(4)
#  opportunity_id :integer(4)
#  role           :string(32)
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactOpportunity do
  before(:each) do
    @valid_attributes = {
      :contact => mock_model(Contact),
      :opportunity => mock_model(Opportunity)
    }
  end

  it "should create a new instance given valid attributes" do
    ContactOpportunity.create!(@valid_attributes)
  end
end
