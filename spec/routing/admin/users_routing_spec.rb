# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect(get: "/admin").to route_to(controller: "admin/users", action: "index")
    end

    it "recognizes and generates #new" do
      expect(get: "/admin/users/new").to route_to(controller: "admin/users", action: "new")
    end

    it "recognizes and generates #create" do
      expect(post: "/admin/users").to route_to(controller: "admin/users", action: "create")
    end

    it "recognizes and generates #show" do
      expect(get: "/admin/users/1").to route_to(controller: "admin/users", action: "show", id: "1")
    end

    it "recognizes and generates #edit" do
      expect(get: "/admin/users/1/edit").to route_to(controller: "admin/users", action: "edit", id: "1")
    end

    it "recognizes and generates #update" do
      expect(put: "/admin/users/1").to route_to(controller: "admin/users", action: "update", id: "1")
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/admin/users/1").to route_to(controller: "admin/users", action: "destroy", id: "1")
    end
  end
end
