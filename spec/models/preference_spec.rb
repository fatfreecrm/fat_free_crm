# == Schema Information
# Schema version: 27
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
    @user = Factory(:user)
    @magoody = Base64.encode64(Marshal.dump("magoody"))
  end

  it "should create a new instance given valid attributes" do
    Preference.create!(:user => @user, :name => "name", :value => "value")
  end

  describe "get user preference" do
    it "should find and decode existing user preference by its name" do
      @preference = Factory(:preference, :user => @user, :name => "thingymabob", :value => @magoody)
      @user.preference[:thingymabob].should == "magoody"
      @user.preference["thingymabob"].should == "magoody"
    end

    it "should return nil if user preference doesn't exist" do
      @user.preference[:cool].should == nil
    end

    it "should return correct user_id" do
      @preference = Factory(:preference, :user => @user, :name => "thingymabob", :value => @magoody)
      @user.preference[:user_id].should == @user.id
    end

    it "should disregard other user's preference with the same name" do
      @preference = Factory(:preference, :user => Factory(:user), :name => "thingymabob", :value => @magoody)
      @user.preference[:thingymabob].should == nil
    end
  end

  describe "set user preference" do
    it "should create new user preference" do
      @user.preference[:hello] = "magoody"
      @user.reload.preference[:hello].should == "magoody"
    end

    it "should update existing user preference" do
      @preference = Factory(:preference, :user => @user, :name => "thingymabob", :value => @magoody)
      @user.preference[:thingymabob] = "thingy"
      @user.reload.preference[:thingymabob].should == "thingy"
    end
  end
end
