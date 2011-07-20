require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EmailsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/emails" }.should route_to(:controller => "emails", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/emails/new" }.should route_to(:controller => "emails", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/emails/1" }.should route_to(:controller => "emails", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/emails/1/edit" }.should route_to(:controller => "emails", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/emails" }.should route_to(:controller => "emails", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/emails/1" }.should route_to(:controller => "emails", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/emails/1" }.should route_to(:controller => "emails", :action => "destroy", :id => "1")
    end
  end
end
