# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: settings
#
#  id            :integer         not null, primary key
#  name          :string(32)      default(""), not null
#  value         :text
#  created_at    :datetime
#  updated_at    :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Setting do

  it "should create a new instance given valid attributes" do
    Setting.create!(:name => "name", :value => "value")
  end

  it "should find existing setting by its name using [] or method notations, and cache settings" do
    @setting = FactoryGirl.create(:setting, :name => "thingymabob", :value => "magoody")
    Setting.cache.has_key?("thingymabob").should == false
    Setting[:thingymabob].should == "magoody"
    Setting.cache.has_key?("thingymabob").should == true
    Setting.thingymabob.should == "magoody"
  end

  it "should use value from YAML if setting is missing from database" do
    @setting = FactoryGirl.create(:setting, :name => "magoody", :value => nil)
    Setting.yaml_settings.merge!(:magoody => "thingymabob")
    Setting[:magoody].should == "thingymabob"
    Setting.magoody.should == "thingymabob"
  end

  it "should save a new value of a setting using []= or method notation" do
    Setting[:hello] = "world"
    Setting[:hello].should == "world"
    Setting.hello.should == "world"

    Setting.world = "hello"
    Setting.world.should == "hello"
    Setting[:world].should == "hello"
  end
  
  it "should handle false and nil values correctly" do
    Setting[:hello] = false
    Setting[:hello].should == false
    Setting.hello.should == false
  end
end

