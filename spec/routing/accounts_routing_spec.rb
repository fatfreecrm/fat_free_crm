require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "accounts", :action => "index").should == "/accounts"
    end
  
    it "maps #new" do
      route_for(:controller => "accounts", :action => "new").should == "/accounts/new"
    end
  
    it "maps #show" do
      route_for(:controller => "accounts", :action => "show", :id => "1").should == "/accounts/1"
    end

    it "maps #create" do
      route_for(:controller => "accounts", :action => "create").should == { :path => "/accounts", :method => :post }
    end 
  
    it "maps #edit" do
      route_for(:controller => "accounts", :action => "edit", :id => "1").should == "/accounts/1/edit"
    end
  
    it "maps #update" do
      route_for(:controller => "accounts", :action => "update", :id => "1").should == { :path => "/accounts/1", :method => :put }
    end
  
    it "maps #destroy" do
      route_for(:controller => "accounts", :action => "destroy", :id => "1").should == { :path => "/accounts/1", :method => :delete }
    end

    it "maps #search" do
      route_for(:controller => "accounts", :action => "search", :id => "1").should == "/accounts/search/1"
    end

    it "maps #auto_complete" do
      route_for(:controller => "accounts", :action => "auto_complete", :id => "1").should == "/accounts/auto_complete/1"
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

    it "should generate params for #search" do
      params_from(:get, "/accounts/search/1").should == {:controller => "accounts", :action => "search", :id => "1"}
    end

    it "should generate params for #auto_complete" do
      params_from(:post, "/accounts/auto_complete/1").should == {:controller => "accounts", :action => "auto_complete", :id => "1"}
    end
  end
end
