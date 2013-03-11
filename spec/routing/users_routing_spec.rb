require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/users" }.should route_to(:controller => "users", :action => "index")
    end

    it "recognizes and generates #new as /signup" do
      { :get => "/signup" }.should route_to(:controller => "registrations", :action => "new")
    end

    it "recognizes and generates #show as /profile" do
      { :get => "/profile" }.should route_to(:controller => "users", :action => "show")
    end

    it "recognizes and generates #edit" do
      { :get => "/users/1/edit" }.should route_to(:controller => "users", :action => "edit", :id => "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      { :get => "/opportunities/aaron/edit" }.should_not be_routable
    end

    it "recognizes and generates #create" do
      { :post => "/users" }.should route_to(:controller => "users", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/users/1" }.should route_to(:controller => "users", :action => "update", :id => "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      { :put => "/opportunities/aaron" }.should_not be_routable
    end

    it "recognizes and generates #destroy" do
      { :delete => "/users/1" }.should route_to(:controller => "users", :action => "destroy", :id => "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      { :delete => "/opportunities/aaron" }.should_not be_routable
    end

    it "should generate params for #avatar" do
      { :get => "/users/1/avatar" }.should route_to( :controller => "users", :action => "avatar", :id => "1" )
    end

    it "doesn't recognize #avatar with non-numeric id" do
      { :get => "/opportunities/aaron/avatar" }.should_not be_routable
    end

    it "should generate params for #upload_avatar" do
      { :put => "/users/1/upload_avatar" }.should route_to( :controller => "users", :action => "upload_avatar", :id => "1" )
    end

    it "doesn't recognize #upload_avatar with non-numeric id" do
      { :put => "/opportunities/aaron/upload_avatar" }.should_not be_routable
    end

    it "should generate params for #password" do
      { :get => "/users/1/password" }.should route_to( :controller => "users", :action => "password", :id => "1" )
    end

    it "doesn't recognize #password with non-numeric id" do
      { :get => "/opportunities/aaron/password" }.should_not be_routable
    end

    it "should generate params for #change_password" do
      { :put => "/users/1/change_password" }.should route_to( :controller => "users", :action => "change_password", :id => "1" )
    end

    it "doesn't recognize #change_password with non-numeric id" do
      { :put => "/opportunities/aaron/change_password" }.should_not be_routable
    end
  end
end

