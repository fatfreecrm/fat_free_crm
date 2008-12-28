require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "opportunities", :action => "index").should == "/opportunities"
    end
  
    it "should map #new" do
      route_for(:controller => "opportunities", :action => "new").should == "/opportunities/new"
    end
  
    it "should map #show" do
      route_for(:controller => "opportunities", :action => "show", :id => 1).should == "/opportunities/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "opportunities", :action => "edit", :id => 1).should == "/opportunities/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "opportunities", :action => "update", :id => 1).should == "/opportunities/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "opportunities", :action => "destroy", :id => 1).should == "/opportunities/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/opportunities").should == {:controller => "opportunities", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/opportunities/new").should == {:controller => "opportunities", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/opportunities").should == {:controller => "opportunities", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/opportunities/1").should == {:controller => "opportunities", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/opportunities/1/edit").should == {:controller => "opportunities", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/opportunities/1").should == {:controller => "opportunities", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/opportunities/1").should == {:controller => "opportunities", :action => "destroy", :id => "1"}
    end
  end
end
