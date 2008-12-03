require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "contacts", :action => "index").should == "/contacts"
    end
  
    it "should map #new" do
      route_for(:controller => "contacts", :action => "new").should == "/contacts/new"
    end
  
    it "should map #show" do
      route_for(:controller => "contacts", :action => "show", :id => 1).should == "/contacts/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "contacts", :action => "edit", :id => 1).should == "/contacts/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "contacts", :action => "update", :id => 1).should == "/contacts/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "contacts", :action => "destroy", :id => 1).should == "/contacts/1"
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
  end
end
