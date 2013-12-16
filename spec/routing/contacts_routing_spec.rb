# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/contacts" }.should route_to(:controller => "contacts", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/contacts/new" }.should route_to(:controller => "contacts", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/contacts/1" }.should route_to(:controller => "contacts", :action => "show", :id => "1")
    end

    it "doesn't recognize #show with non-numeric id" do
      { :get => "/contacts/aaron" }.should_not be_routable
    end

    it "recognizes and generates #edit" do
      { :get => "/contacts/1/edit" }.should route_to(:controller => "contacts", :action => "edit", :id => "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      { :get => "/campaigns/aaron/edit" }.should_not be_routable
    end

    it "recognizes and generates #create" do
      { :post => "/contacts" }.should route_to(:controller => "contacts", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/contacts/1" }.should route_to(:controller => "contacts", :action => "update", :id => "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      { :put => "/campaigns/aaron" }.should_not be_routable
    end

    it "recognizes and generates #destroy" do
      { :delete => "/contacts/1" }.should route_to(:controller => "contacts", :action => "destroy", :id => "1")
    end

    it "doesn't recognize #delete with non-numeric id" do
      { :delete => "/campaigns/aaron" }.should_not be_routable
    end

    it "recognizes and generates #auto_complete" do
      { :get => "/contacts/auto_complete" }.should route_to( :controller => "contacts", :action => "auto_complete" )
    end
  end
end

