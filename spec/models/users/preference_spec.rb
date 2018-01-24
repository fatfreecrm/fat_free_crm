# frozen_string_literal: true

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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
      expect(@user.preference[:thingymabob]).to eq("magoody")
      expect(@user.preference["thingymabob"]).to eq("magoody")
    end

    it "should return nil if user preference doesn't exist" do
      expect(@user.preference[:cool]).to eq(nil)
    end

    it "should return correct user_id" do
      @preference = create(:preference, user: @user, name: "thingymabob", value: @magoody)
      expect(@user.preference[:user_id]).to eq(@user.id)
    end

    it "should disregard other user's preference with the same name" do
      @preference = create(:preference, user: create(:user), name: "thingymabob", value: @magoody)
      expect(@user.preference[:thingymabob]).to eq(nil)
    end

    it "should not fail is user is nil" do
      @preference = create(:preference, user: nil, name: "thingymabob", value: @magoody)
      expect(@preference[:thingymabob]).to eq(nil)
    end
  end

  describe "set user preference" do
    it "should create new user preference" do
      @user.preference[:hello] = "magoody"
      expect(@user.reload.preference[:hello]).to eq("magoody")
    end

    it "should update existing user preference" do
      @preference = create(:preference, user: @user, name: "thingymabob", value: @magoody)
      @user.preference[:thingymabob] = "thingy"
      expect(@user.reload.preference[:thingymabob]).to eq("thingy")
    end
  end
end
