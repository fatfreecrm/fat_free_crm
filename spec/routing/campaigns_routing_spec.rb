require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CampaignsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/campaigns" }.should route_to(:controller => "campaigns", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/campaigns/new" }.should route_to(:controller => "campaigns", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/campaigns/1" }.should route_to(:controller => "campaigns", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/campaigns/1/edit" }.should route_to(:controller => "campaigns", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/campaigns" }.should route_to(:controller => "campaigns", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/campaigns/1" }.should route_to(:controller => "campaigns", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/campaigns/1" }.should route_to(:controller => "campaigns", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #search" do
      { :get => "/campaigns/search" }.should route_to( :controller => "campaigns", :action => "search" )
    end

    it "recognizes and generates #auto_complete" do
      { :post => "/campaigns/auto_complete" }.should route_to( :controller => "campaigns", :action => "auto_complete" )
    end

    it "recognizes and generates #filter" do
      { :post => "/campaigns/filter" }.should route_to( :controller => "campaigns", :action => "filter" )
    end
  end
end
