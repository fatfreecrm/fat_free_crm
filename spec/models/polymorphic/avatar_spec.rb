# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: avatars
#
#  id                 :integer         not null, primary key
#  user_id            :integer
#  entity_id          :integer
#  entity_type        :string(255)
#  image_file_size    :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Avatar do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  it "should create a new instance given valid attributes" do
    FactoryGirl.create(:avatar, :entity => @user).should be_valid
  end

  it "user should have one avatar as entity" do
    avatar = FactoryGirl.create(:avatar, :entity => @user)
    @user.avatar.should == avatar
  end

  it "user might have many avatars as owner" do
    avatars = [
      FactoryGirl.create(:avatar, :user=> @user, :entity => FactoryGirl.create(:user)),
      FactoryGirl.create(:avatar, :user=> @user, :entity => FactoryGirl.create(:user))
    ]
    @user.avatars.should == avatars
  end

end

