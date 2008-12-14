# == Schema Information
# Schema version: 10
#
# Table name: accounts
#
#  id               :integer(4)      not null, primary key
#  uuid             :string(36)
#  user_id          :integer(4)
#  name             :string(64)      default(""), not null
#  access           :string(8)       default("Private")
#  notes            :string(255)
#  website          :string(64)
#  phone            :string(32)
#  fax              :string(32)
#  billing_address  :string(255)
#  shipping_address :string(255)
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do
  before(:each) do
    @valid_attributes = {
      :name => "Test Account",
      :user => mock_model(User)
    }
  end

  it "should create a new instance given valid attributes" do
    Account.create!(@valid_attributes)
  end
end
