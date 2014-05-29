# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: preferences
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  name       :string(32)      default(""), not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Preference do
  before(:each) do
    @user = create(:user)
    @magoody = Base64.encode64(Marshal.dump("magoody"))
  end

  it "should create a new instance given valid attributes" do
    Preference.create!(user: @user, name: "name", value: "value")
  end

  describe "get user preference" do
    it "should find and decode existing user preference by its name" do
      @preference = create(:preference, user: @user, name: "thingymabob", value: @magoody)
      @user.preference[:thingymabob].should == "magoody"
      @user.preference["thingymabob"].should == "magoody"
    end

    it "should return nil if user preference doesn't exist" do
      @user.preference[:cool].should == nil
    end

    it "should return correct user_id" do
      @preference = create(:preference, user: @user, name: "thingymabob", value: @magoody)
      @user.preference[:user_id].should == @user.id
    end

    it "should disregard other user's preference with the same name" do
      @preference = create(:preference, user: create(:user), name: "thingymabob", value: @magoody)
      @user.preference[:thingymabob].should == nil
    end

    it "should not fail is user is nil" do
      @preference = create(:preference, user: nil, name: "thingymabob", value: @magoody)
      @preference[:thingymabob].should == nil
    end
  end

  describe "set user preference" do
    it "should create new user preference" do
      @user.preference[:hello] = "magoody"
      @user.reload.preference[:hello].should == "magoody"
    end

    it "should update existing user preference" do
      @preference = create(:preference, user: @user, name: "thingymabob", value: @magoody)
      @user.preference[:thingymabob] = "thingy"
      @user.reload.preference[:thingymabob].should == "thingy"
    end
  end
end
