require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Array do
  describe "limit" do
    it "should return original array if nil argument" do
      array = ["h", "e", "l", "l", "o"]
      array.limit(nil).should == array
    end
    it "should return the first 3 elements of the array" do
      array = ["h", "e", "l", "l", "o"]
      array.limit(3).should == ["h", "e", "l"]
    end
    it "should return entire array if argument is larger than the length of the array" do
      array = ["h", "e", "l", "l", "o"]
      array.limit(6).should == array
    end
    it "should return entire arry if argument is a string" do
      array = ["h", "e", "l", "l", "o"]
      array.limit("string").should == array
    end
    it "should return entire arry if argument is a float" do
      array = ["h", "e", "l", "l", "o"]
      array.limit(5.5).should == array
    end
  end
  
end