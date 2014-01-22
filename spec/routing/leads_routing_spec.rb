# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/leads" }.should route_to(:controller => "leads", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/leads/new" }.should route_to(:controller => "leads", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/leads/1" }.should route_to(:controller => "leads", :action => "show", :id => "1")
    end

    it "doesn't recognize #show with non-numeric id" do
      { :get => "/leads/aaron" }.should_not be_routable
    end

    it "recognizes and generates #edit" do
      { :get => "/leads/1/edit" }.should route_to(:controller => "leads", :action => "edit", :id => "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      { :get => "/leads/aaron/edit" }.should_not be_routable
    end

    it "recognizes and generates #create" do
      { :post => "/leads" }.should route_to(:controller => "leads", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/leads/1" }.should route_to(:controller => "leads", :action => "update", :id => "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      { :put => "/leads/aaron" }.should_not be_routable
    end

    it "recognizes and generates #destroy" do
      { :delete => "/leads/1" }.should route_to(:controller => "leads", :action => "destroy", :id => "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      { :delete => "/leads/aaron" }.should_not be_routable
    end

    it "recognizes and generates #auto_complete" do
      { :get => "/leads/auto_complete" }.should route_to( :controller => "leads", :action => "auto_complete" )
    end

    it "recognizes and generates #filter" do
      { :post => "/leads/filter" }.should route_to( :controller => "leads", :action => "filter" )
    end

    it "should generate params for #convert" do
      { :get => "/leads/1/convert" }.should route_to( :controller => "leads", :action => "convert", :id => "1" )
    end

    it "doesn't recognize #convert with non-numeric id" do
      { :get => "/leads/aaron/convert" }.should_not be_routable
    end

    it "should generate params for #promote" do
      { :put => "/leads/1/promote" }.should route_to( :controller => "leads", :action => "promote", :id => "1" )
    end

    it "doesn't recognize #promote with non-numeric id" do
      { :put => "/leads/aaron/promote" }.should_not be_routable
    end

    it "should generate params for #reject" do
      { :put => "/leads/1/reject" }.should route_to( :controller => "leads", :action => "reject", :id => "1" )
    end

    it "doesn't recognize #reject with non-numeric id" do
      { :put => "/leads/aaron/reject" }.should_not be_routable
    end

  end
end
