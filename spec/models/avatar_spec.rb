# == Schema Information
# Schema version: 27
#
# Table name: avatars
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  entity_id          :integer(4)
#  entity_type        :string(255)
#  image_file_size    :integer(4)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Avatar do
  before(:each) do
    @user = Factory(:user)
  end

  it "should create a new instance given valid attributes" do
    Factory(:avatar, :entity => @user).should be_valid
  end

  it "user should have one avatar as entity" do
    avatar = Factory(:avatar, :entity => @user)
    @user.avatar.should == avatar
  end

  it "user might have many avatars as owner" do
    avatars = [
      Factory(:avatar, :user=> @user, :entity => Factory(:user)),
      Factory(:avatar, :user=> @user, :entity => Factory(:user))
    ]
    @user.avatars.should == avatars
  end

end
