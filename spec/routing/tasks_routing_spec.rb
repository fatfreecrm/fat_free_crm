require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "tasks", :action => "index").should == "/tasks"
    end
  
    it "maps #new" do
      route_for(:controller => "tasks", :action => "new").should == "/tasks/new"
    end
  
    it "maps #show" do
      route_for(:controller => "tasks", :action => "show", :id => "1").should == "/tasks/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "tasks", :action => "edit", :id => "1").should == "/tasks/1/edit"
    end
  
    it "maps #create" do
      route_for(:controller => "tasks", :action => "create").should == { :path => "/tasks", :method => :post }
    end 

    it "maps #update" do
      route_for(:controller => "tasks", :action => "update", :id => "1").should == { :path => "/tasks/1", :method => :put }
    end
  
    it "maps #destroy" do
      route_for(:controller => "tasks", :action => "destroy", :id => "1").should == { :path => "/tasks/1", :method => :delete }
    end

    it "maps #complete" do
      route_for(:controller => "tasks", :action => "complete", :id => "1").should == { :path => "/tasks/1/complete", :method => :put }
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/tasks").should == {:controller => "tasks", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/tasks/new").should == {:controller => "tasks", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/tasks").should == {:controller => "tasks", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/tasks/1").should == {:controller => "tasks", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/tasks/1/edit").should == {:controller => "tasks", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/tasks/1").should == {:controller => "tasks", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/tasks/1").should == {:controller => "tasks", :action => "destroy", :id => "1"}
    end

    it "should generate params for #complete" do
      params_from(:put, "/tasks/1/complete").should == {:controller => "tasks", :action => "complete", :id => "1"}
    end
  end
end
