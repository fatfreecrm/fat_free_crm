require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class TestCallback < FatFreeCRM::Callback::Base
  insert_before :test_before do |view, context|
    "BEFORE-"
  end
  insert_after :test_after do |view, context|
    "-AFTER"
  end
  replace :test_replace do |view, context|
    "REPLACE"
  end
  remove :test_remove
  
  def test_legacy(view, context={})
    "LEGACY"
  end
end

include FatFreeCRM::Callback::Helper
include ActionView::Helpers::CaptureHelper

def test_hook(position)
  Haml::Engine.new(%Q^
= hook("test_#{position}".to_sym, ActionView::Base.new) do
  BLOCK^).render.gsub("\n",'')
end

describe FatFreeCRM::Callback do 
  it "should insert content before the block" do
    test_hook(:before).should == "BEFORE-BLOCK"
  end
  
  it "should insert content after the block" do
    test_hook(:after).should == "BLOCK-AFTER"
  end
  
  it "should replace the content of the block" do
    test_hook(:replace).should == "REPLACE"
  end
  
  it "should remove the block" do
    test_hook(:remove).should == ""
  end
  
  it "should still work for legacy hooks" do
  Haml::Engine.new(%Q^
= hook(:test_legacy, ActionView::Base.new)
  ^).render.gsub("\n",'').should == "LEGACY"
  end
end
