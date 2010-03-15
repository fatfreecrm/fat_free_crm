# == Schema Information
# Schema version: 26
#
# Table name: address
#
#  id                 :integer(4)      not null, primary key
#  street1            :string(255)
#  street2            :string(255)
#  city               :string(255)
#  state              :string(255)
#  zipcode            :string(255)
#  country            :string(2)
#  full_address       :string(255)
#  address_type       :string(255)
#  addressable_id     :integer(4)
#  addressable_type   :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Address.create!(:street1 => "street1", :street2 => "street2", :city => "city", :state => "state", :zipcode => "zipcode", :country => "country", :full_address => "fa", :address_type => "Lead", :addressable => Factory(:lead))
  end
end
