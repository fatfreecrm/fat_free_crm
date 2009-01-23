require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "tasks", :action => "index").should == "/tasks"
    end
  
    it "should map #new" do
      route_for(:controller => "tasks", :action => "new").should == "/tasks/new"
    end
  
    it "should map #show" do
      route_for(:controller => "tasks", :action => "show", :id => 1).should == "/tasks/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "tasks", :action => "edit", :id => 1).should == "/tasks/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "tasks", :action => "update", :id => 1).should == "/tasks/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "tasks", :action => "destroy", :id => 1).should == "/tasks/1"
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
  end
end
