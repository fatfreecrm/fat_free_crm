require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/accounts" }.should route_to(:controller => "accounts", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/accounts/new" }.should route_to(:controller => "accounts", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/accounts/1" }.should route_to(:controller => "accounts", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/accounts/1/edit" }.should route_to(:controller => "accounts", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/accounts" }.should route_to(:controller => "accounts", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/accounts/1" }.should route_to(:controller => "accounts", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/accounts/1" }.should route_to(:controller => "accounts", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #search" do
      { :get => "/accounts/search" }.should route_to( :controller => "accounts", :action => "search" )
    end

    it "recognizes and generates #auto_complete" do
      { :post => "/accounts/auto_complete" }.should route_to( :controller => "accounts", :action => "auto_complete" )
    end
  end
end
