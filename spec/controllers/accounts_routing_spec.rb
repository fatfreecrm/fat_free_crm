require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "accounts", :action => "index").should == "/accounts"
    end
  
    it "should map #new" do
      route_for(:controller => "accounts", :action => "new").should == "/accounts/new"
    end
  
    it "should map #show" do
      route_for(:controller => "accounts", :action => "show", :id => 1).should == "/accounts/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "accounts", :action => "edit", :id => 1).should == "/accounts/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "accounts", :action => "update", :id => 1).should == "/accounts/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "accounts", :action => "destroy", :id => 1).should == "/accounts/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/accounts").should == {:controller => "accounts", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/accounts/new").should == {:controller => "accounts", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/accounts").should == {:controller => "accounts", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/accounts/1").should == {:controller => "accounts", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/accounts/1/edit").should == {:controller => "accounts", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/accounts/1").should == {:controller => "accounts", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/accounts/1").should == {:controller => "accounts", :action => "destroy", :id => "1"}
    end
  end
end
