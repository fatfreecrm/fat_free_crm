# == Schema Information
# Schema version: 10
#
# Table name: settings
#
#  id            :integer(4)      not null, primary key
#  name          :string(32)      default(""), not null
#  value         :text
#  default_value :text
#  created_at    :datetime
#  updated_at    :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Setting do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Setting.create!(@valid_attributes)
  end
end
