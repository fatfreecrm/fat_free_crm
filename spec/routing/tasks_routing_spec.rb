# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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

    it "doesn't recognize #show with non-numeric id" do
      { :get => "/tasks/aaron" }.should_not be_routable
    end

    it "recognizes and generates #edit" do
      { :get => "/tasks/1/edit" }.should route_to(:controller => "tasks", :action => "edit", :id => "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      { :get => "/opportunities/aaron/edit" }.should_not be_routable
    end

    it "recognizes and generates #create" do
      { :post => "/tasks" }.should route_to(:controller => "tasks", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/tasks/1" }.should route_to(:controller => "tasks", :action => "update", :id => "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      { :put => "/opportunities/aaron" }.should_not be_routable
    end

    it "recognizes and generates #destroy" do
      { :delete => "/tasks/1" }.should route_to(:controller => "tasks", :action => "destroy", :id => "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      { :delete => "/opportunities/aaron" }.should_not be_routable
    end

    it "recognizes and generates #filter" do
      { :post => "/tasks/filter" }.should route_to( :controller => "tasks", :action => "filter" )
    end

    it "should generate params for #complete" do
      { :put => "/tasks/1/complete" }.should route_to( :controller => "tasks", :action => "complete", :id => "1" )
    end

    it "doesn't recognize #complete with non-numeric id" do
      { :put => "/opportunities/aaron/complete" }.should_not be_routable
    end
  end
end
