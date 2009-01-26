# == Schema Information
# Schema version: 15
#
# Table name: tasks
#
#  id           :integer(4)      not null, primary key
#  uuid         :string(36)
#  user_id      :integer(4)
#  assigned_to  :integer(4)
#  name         :string(255)     default(""), not null
#  asset_id     :integer(4)
#  asset_type   :string(255)
#  priority     :string(32)
#  category     :string(32)
#  due_at       :datetime
#  completed_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Task do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Task.create!(@valid_attributes)
  end
end
