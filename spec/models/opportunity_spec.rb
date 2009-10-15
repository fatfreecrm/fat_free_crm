# == Schema Information
# Schema version: 23
#
# Table name: opportunities
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  campaign_id :integer(4)
#  assigned_to :integer(4)
#  name        :string(64)      default(""), not null
#  access      :string(8)       default("Private")
#  source      :string(32)
#  stage       :string(32)
#  probability :integer(4)
#  amount      :decimal(12, 2)
#  discount    :decimal(12, 2)
#  closes_on   :date
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Opportunity do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Opportunity.create!(:name => "Opportunity")
  end

  it "should be possible to create opportunity with the same name" do
    first  = Factory(:opportunity, :name => "Hello", :user => @current_user)
    lambda { Factory(:opportunity, :name => "Hello", :user => @current_user) }.should_not raise_error(ActiveRecord::RecordInvalid)
  end

end
