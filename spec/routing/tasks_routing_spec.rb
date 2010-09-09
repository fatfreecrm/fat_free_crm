require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/tasks" }.should route_to(:controller => "tasks", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/tasks/new" }.should route_to(:controller => "tasks", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/tasks/1" }.should route_to(:controller => "tasks", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/tasks/1/edit" }.should route_to(:controller => "tasks", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/tasks" }.should route_to(:controller => "tasks", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/tasks/1" }.should route_to(:controller => "tasks", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/tasks/1" }.should route_to(:controller => "tasks", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #filter" do
      { :post => "/tasks/filter" }.should route_to( :controller => "tasks", :action => "filter" )
    end

    it "should generate params for #complete" do
      { :put => "/tasks/1/complete" }.should route_to( :controller => "tasks", :action => "complete", :id => "1" )
    end
  end
end
