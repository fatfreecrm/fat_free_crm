# == Schema Information
# Schema version: 23
#
# Table name: leads
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  first_name  :string(64)      default(""), not null
#  last_name   :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  title       :string(64)
#  company     :string(64)
#  source      :string(32)
#  status      :string(32)
#  referred_by :string(64)
#  email       :string(64)
#  alt_email   :string(64)
#  phone       :string(32)
#  mobile      :string(32)
#  blog        :string(128)
#  linkedin    :string(128)
#  facebook    :string(128)
#  twitter     :string(128)
#  address     :string(255)
#  rating      :integer(4)      default(0), not null
#  do_not_call :boolean(1)      not null
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lead do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Lead.create!(:first_name => "Billy", :last_name => "Bones")
  end

end
