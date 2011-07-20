require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/users" }.should route_to(:controller => "users", :action => "index")
    end

    # it "recognizes and generates #new" do
    #   { :get => "/users/new" }.should route_to(:controller => "users", :action => "new")
    # end

    it "recognizes and generates #new as /signup" do
      { :get => "/signup" }.should route_to(:controller => "users", :action => "new")
    end

    # it "recognizes and generates #show" do
    #   { :get => "/users/123" }.should route_to(:controller => "users", :action => "show", :id => "1")
    # end

    it "recognizes and generates #show as /profile" do
      { :get => "/profile" }.should route_to(:controller => "users", :action => "show")
    end

    it "recognizes and generates #edit" do
      { :get => "/users/1/edit" }.should route_to(:controller => "users", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/users" }.should route_to(:controller => "users", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/users/1" }.should route_to(:controller => "users", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/users/1" }.should route_to(:controller => "users", :action => "destroy", :id => "1")
    end

    it "should generate params for #avatar" do
      { :get => "/users/1/avatar" }.should route_to( :controller => "users", :action => "avatar", :id => "1" )
    end

    it "should generate params for #upload_avatar" do
      { :put => "/users/1/upload_avatar" }.should route_to( :controller => "users", :action => "upload_avatar", :id => "1" )
    end

    it "should generate params for #password" do
      { :get => "/users/1/password" }.should route_to( :controller => "users", :action => "password", :id => "1" )
    end

    it "should generate params for #change_password" do
      { :put => "/users/1/change_password" }.should route_to( :controller => "users", :action => "change_password", :id => "1" )
    end
  end
end
