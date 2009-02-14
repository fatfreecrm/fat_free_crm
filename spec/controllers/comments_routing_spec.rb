require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "comments", :action => "index").should == "/comments"
    end
  
    it "should map #new" do
      route_for(:controller => "comments", :action => "new").should == "/comments/new"
    end
  
    it "should map #show" do
      route_for(:controller => "comments", :action => "show", :id => 1).should == "/comments/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "comments", :action => "edit", :id => 1).should == "/comments/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "comments", :action => "update", :id => 1).should == "/comments/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "comments", :action => "destroy", :id => 1).should == "/comments/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/comments").should == {:controller => "comments", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/comments/new").should == {:controller => "comments", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/comments").should == {:controller => "comments", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/comments/1").should == {:controller => "comments", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/comments/1/edit").should == {:controller => "comments", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/comments/1").should == {:controller => "comments", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/comments/1").should == {:controller => "comments", :action => "destroy", :id => "1"}
    end
  end
end
