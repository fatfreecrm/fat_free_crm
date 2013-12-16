# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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

    it "doesn't recognize #show with non-numeric id" do
      { :get => "/accounts/aaron" }.should_not be_routable
    end

    it "recognizes and generates #edit" do
      { :get => "/accounts/1/edit" }.should route_to(:controller => "accounts", :action => "edit", :id => "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      { :get => "/accounts/aaron/edit" }.should_not be_routable
    end

    it "recognizes and generates #create" do
      { :post => "/accounts" }.should route_to(:controller => "accounts", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/accounts/1" }.should route_to(:controller => "accounts", :action => "update", :id => "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      { :put => "/accounts/aaron" }.should_not be_routable
    end

    it "recognizes and generates #destroy" do
      { :delete => "/accounts/1" }.should route_to(:controller => "accounts", :action => "destroy", :id => "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      { :delete => "/accounts/aaron" }.should_not be_routable
    end

    it "recognizes and generates #auto_complete" do
      { :get => "/accounts/auto_complete" }.should route_to( :controller => "accounts", :action => "auto_complete" )
    end
  end
end

