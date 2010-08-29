require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin" }.should route_to( :controller => "admin/users", :action => "index" )
    end

    it "recognizes and generates #new" do
      { :get => "/admin/users/new" }.should route_to( :controller => "admin/users", :action => "new" )
    end

    it "recognizes and generates #create" do
      { :post => "/admin/users" }.should route_to( :controller => "admin/users", :action => "create" )
    end

    it "recognizes and generates #show" do
      { :get => "/admin/users/1" }.should route_to( :controller => "admin/users", :action => "show", :id => "1" )
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/users/1/edit" }.should route_to( :controller => "admin/users", :action => "edit", :id => "1" )
    end

    it "recognizes and generates #update" do
      { :put => "/admin/users/1" }.should route_to( :controller => "admin/users", :action => "update", :id => "1" )
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/users/1" }.should route_to( :controller => "admin/users", :action => "destroy", :id => "1" )
    end
  end
end
