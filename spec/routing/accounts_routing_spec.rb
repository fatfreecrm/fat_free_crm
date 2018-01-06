# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect(get: "/accounts").to route_to(controller: "accounts", action: "index")
    end

    it "recognizes and generates #new" do
      expect(get: "/accounts/new").to route_to(controller: "accounts", action: "new")
    end

    it "recognizes and generates #show" do
      expect(get: "/accounts/1").to route_to(controller: "accounts", action: "show", id: "1")
    end

    it "doesn't recognize #show with non-numeric id" do
      expect(get: "/accounts/aaron").not_to be_routable
    end

    it "recognizes and generates #edit" do
      expect(get: "/accounts/1/edit").to route_to(controller: "accounts", action: "edit", id: "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      expect(get: "/accounts/aaron/edit").not_to be_routable
    end

    it "recognizes and generates #create" do
      expect(post: "/accounts").to route_to(controller: "accounts", action: "create")
    end

    it "recognizes and generates #update" do
      expect(put: "/accounts/1").to route_to(controller: "accounts", action: "update", id: "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      expect(put: "/accounts/aaron").not_to be_routable
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/accounts/1").to route_to(controller: "accounts", action: "destroy", id: "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      expect(delete: "/accounts/aaron").not_to be_routable
    end

    it "recognizes and generates #auto_complete" do
      expect(get: "/accounts/auto_complete").to route_to(controller: "accounts", action: "auto_complete")
    end
  end
end
