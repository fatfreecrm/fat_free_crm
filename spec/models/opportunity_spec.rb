# == Schema Information
# Schema version: 11
#
# Table name: opportunities
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  account_id  :integer(4)      not null
#  campaign_id :integer(4)
#  name        :string(64)      default(""), not null
#  source      :string(32)
#  stage       :string(32)
#  probability :integer(4)
#  amount      :decimal(12, 2)
#  close_on    :date
#  notes       :text
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Opportunity do
  before(:each) do
    @account = mock_model(Account)
    @valid_attributes = {
      :account_id => @account.id,
      :name => "Excellent Opportunity"
    }
  end

  it "should create a new instance given valid attributes" do
    Opportunity.create!(@valid_attributes)
  end
end
