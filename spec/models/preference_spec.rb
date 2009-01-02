# == Schema Information
# Schema version: 14
#
# Table name: preferences
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  name       :string(32)      default(""), not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Preference do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Preference.create!(@valid_attributes)
  end
end
