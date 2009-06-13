require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "contacts", :action => "index").should == "/contacts"
    end
  
    it "maps #new" do
      route_for(:controller => "contacts", :action => "new").should == "/contacts/new"
    end
  
    it "maps #show" do
      route_for(:controller => "contacts", :action => "show", :id => "1").should == "/contacts/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "contacts", :action => "edit", :id => "1").should == "/contacts/1/edit"
    end
  
    it "maps #create" do
      route_for(:controller => "contacts", :action => "create").should == { :path => "/contacts", :method => :post }
    end 

    it "maps #update" do
      route_for(:controller => "contacts", :action => "update", :id => "1").should == { :path => "/contacts/1", :method => :put }
    end
  
    it "maps #destroy" do
      route_for(:controller => "contacts", :action => "destroy", :id => "1").should == { :path => "/contacts/1", :method => :delete }
    end

    it "maps #search" do
      route_for(:controller => "contacts", :action => "search", :id => "1").should == "/contacts/search/1"
    end

    it "maps #auto_complete" do
      route_for(:controller => "contacts", :action => "auto_complete", :id => "1").should == "/contacts/auto_complete/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/contacts").should == {:controller => "contacts", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/contacts/new").should == {:controller => "contacts", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/contacts").should == {:controller => "contacts", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/contacts/1").should == {:controller => "contacts", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/contacts/1/edit").should == {:controller => "contacts", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/contacts/1").should == {:controller => "contacts", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/contacts/1").should == {:controller => "contacts", :action => "destroy", :id => "1"}
    end

    it "should generate params for #search" do
      params_from(:get, "/contacts/search/1").should == {:controller => "contacts", :action => "search", :id => "1"}
    end

    it "should generate params for #auto_complete" do
      params_from(:post, "/contacts/auto_complete/1").should == {:controller => "contacts", :action => "auto_complete", :id => "1"}
    end
  end
end
