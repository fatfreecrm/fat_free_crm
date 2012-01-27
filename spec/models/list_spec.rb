require 'spec_helper'

describe List do
  it "should parse the controller from the url" do
    ["/controller/action", "controller/action?utf8=%E2%9C%93"].each do |url|
      list = Factory.build(:list, :url => url)
      list.controller.should == "controller"
    end
    list = Factory.build(:list, :url => nil)
    list.controller.should == nil
  end
end
