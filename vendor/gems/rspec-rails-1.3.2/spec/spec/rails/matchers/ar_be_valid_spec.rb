require 'spec_helper'

describe "be_valid" do
  context "with valid attributes" do
    it "returns true" do
      be_valid.matches?(Thing.new(:name => 'thing')).should == true
    end
  end
  
  context "with invalid attributes" do
    it "returns false" do
      be_valid.matches?(Thing.new).should == false
    end
    
    it "adds errors to the errors " do
      expect { Thing.new.should be_valid }.to raise_error(/can't be blank/)
    end
  end
end
