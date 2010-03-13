# == Schema Information
# Schema version: 27
#
# Table name: settings
#
#  id            :integer(4)      not null, primary key
#  name          :string(32)      default(""), not null
#  value         :text
#  default_value :text
#  created_at    :datetime
#  updated_at    :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Setting do

  it "should create a new instance given valid attributes" do
    Setting.create!(:name => "name", :value => "value", :default_value => nil)
  end

  it "should find existing setting by its name using [] or method notations" do
    @setting = Factory(:setting, :name => "thingymabob", :value => Base64.encode64(Marshal.dump("magoody")))
    Setting[:thingymabob].should == "magoody"
    Setting.thingymabob.should == "magoody"
  end

  it "should use :default_value if the value is missing" do
    @setting = Factory(:setting, :name => "magoody", :value => nil, :default_value => Base64.encode64(Marshal.dump("thingymabob")))
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
end
