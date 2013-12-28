# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe EmailsController do
  describe "routing" do

    it "should not recognize #index" do
      { :get => "/emails" }.should_not be_routable
    end

    it "should not recognize #new" do
      { :get => "/emails/new" }.should_not be_routable
    end

    it "should not recognize #show" do
      { :get => "/emails/1" }.should_not be_routable
    end

    it "should not recognize #edit" do
      { :get => "/emails/1/edit" }.should_not be_routable
    end

    it "should not recognize #create" do
      { :post => "/emails" }.should_not be_routable
    end

    it "should not recognize #update" do
      { :put => "/emails/1" }.should_not be_routable
    end

    it "recognizes and generates #destroy" do
      { :delete => "/emails/1" }.should route_to(:controller => "emails", :action => "destroy", :id => "1")
    end
  end
end
