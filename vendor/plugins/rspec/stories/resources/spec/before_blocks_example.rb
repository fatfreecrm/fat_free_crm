$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. .. lib])
require 'spec'

Spec::Runner.configure do |config|
  config.before(:suite) do
    $before_suite = "before suite"
  end
  config.before(:each) do
    @before_each = "before each"
  end
  config.before(:all) do
    @before_all = "before all"
  end
end

describe "stuff in before blocks" do
  describe "with :suite" do
    it "should be available in the example" do
      $before_suite.should == "before suite"
    end
  end
  describe "with :all" do
    it "should be available in the example" do
      @before_all.should == "before all"
    end
  end
  describe "with :each" do
    it "should be available in the example" do
      @before_each.should == "before each"
    end
  end
end