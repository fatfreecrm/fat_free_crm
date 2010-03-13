# == Schema Information
# Schema version: 27
#
# Table name: permissions
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  asset_id   :integer(4)
#  asset_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  before(:each) do
    @valid_attributes = {
      :user => mock_model(User),
      :asset => mock_model(Account)
    }
  end

  it "should create a new instance given valid attributes" do
    Permission.create!(@valid_attributes)
  end
end
