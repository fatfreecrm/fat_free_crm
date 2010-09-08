require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/opportunities" }.should route_to(:controller => "opportunities", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/opportunities/new" }.should route_to(:controller => "opportunities", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/opportunities/1" }.should route_to(:controller => "opportunities", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/opportunities/1/edit" }.should route_to(:controller => "opportunities", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/opportunities" }.should route_to(:controller => "opportunities", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/opportunities/1" }.should route_to(:controller => "opportunities", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/opportunities/1" }.should route_to(:controller => "opportunities", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #search" do
      { :get => "/opportunities/search" }.should route_to( :controller => "opportunities", :action => "search" )
    end

    it "recognizes and generates #auto_complete" do
      { :post => "/opportunities/auto_complete" }.should route_to( :controller => "opportunities", :action => "auto_complete" )
    end

    it "recognizes and generates #filter" do
      { :post => "/opportunities/filter" }.should route_to( :controller => "opportunities", :action => "filter" )
    end
  end
end
