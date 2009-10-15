# == Schema Information
# Schema version: 23
#
# Table name: accounts
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)
#  assigned_to      :integer(4)
#  name             :string(64)      default(""), not null
#  access           :string(8)       default("Private")
#  website          :string(64)
#  toll_free_phone  :string(32)
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
    login
  end

  it "should create a new instance given valid attributes" do
    Account.create!(:name => "Test Account", :user => Factory(:user))
  end

end
