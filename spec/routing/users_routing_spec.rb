# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "routing" do
    it "recognizes #index" do
      expect(get: "/users").to route_to(controller: "users", action: "index")
    end

    it "recognizes and generates Devise registrations routes" do
      expect(get: "/users/sign_up").to route_to(controller: "registrations", action: "new")
      expect(get: "/users/edit").to route_to(controller: "registrations", action: "edit")
      expect(get: "/users/cancel").to route_to(controller: "registrations", action: "cancel")
      expect(post: "/users").to route_to(controller: "registrations", action: "create")
      expect(put: "/users").to route_to(controller: "registrations", action: "update")
      expect(patch: "/users").to route_to(controller: "registrations", action: "update")
      expect(delete: "/users").to route_to(controller: "registrations", action: "destroy")
    end

    it "recognizes and generates Devise sessions routes" do
      expect(get: "/users/sign_in").to route_to(controller: "sessions", action: "new")
      expect(post: "/users/sign_in").to route_to(controller: "sessions", action: "create")
      expect(delete: "/users/sign_out").to route_to(controller: "sessions", action: "destroy")
    end

    it "recognizes and generates Devise passwords routes" do
      expect(get: "/users/password/new").to route_to(controller: "passwords", action: "new")
      expect(get: "/users/password/edit").to route_to(controller: "passwords", action: "edit")
      expect(post: "/users/password").to route_to(controller: "passwords", action: "create")
      expect(put: "/users/password").to route_to(controller: "passwords", action: "update")
      expect(patch: "/users/password").to route_to(controller: "passwords", action: "update")
    end

    it "recognizes and generates Devise confirmations routes" do
      expect(get: "/users/confirmation/new").to route_to(controller: "confirmations", action: "new")
      expect(get: "/users/confirmation").to route_to(controller: "confirmations", action: "show")
      expect(post: "/users/confirmation").to route_to(controller: "confirmations", action: "create")
    end

    it "recognizes and generates #show as /profile" do
      expect(get: "/profile").to route_to(controller: "users", action: "show")
    end

    it "recognizes and generates #edit" do
      expect(get: "/users/1/edit").to route_to(controller: "users", action: "edit", id: "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      expect(get: "/users/aaron/edit").not_to be_routable
    end

    it "recognizes and generates #update" do
      expect(put: "/users/1").to route_to(controller: "users", action: "update", id: "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      expect(put: "/users/aaron").not_to be_routable
    end

    it "doesn't recognize #destroy" do
      expect(delete: "/users/1").not_to be_routable
    end

    it "doesn't recognize #destroy with non-numeric id" do
      expect(delete: "/users/aaron").not_to be_routable
    end

    it "should generate params for #avatar" do
      expect(get: "/users/1/avatar").to route_to(controller: "users", action: "avatar", id: "1")
    end

    it "doesn't recognize #avatar with non-numeric id" do
      expect(get: "/users/aaron/avatar").not_to be_routable
    end

    it "should generate params for #upload_avatar" do
      expect(put: "/users/1/upload_avatar").to route_to(controller: "users", action: "upload_avatar", id: "1")
    end

    it "doesn't recognize #upload_avatar with non-numeric id" do
      expect(put: "/users/aaron/upload_avatar").not_to be_routable
    end

    it "should generate params for #password" do
      expect(get: "/users/1/password").to route_to(controller: "users", action: "password", id: "1")
    end

    it "doesn't recognize #password with non-numeric id" do
      expect(get: "/users/aaron/password").not_to be_routable
    end

    it "should generate params for #change_password" do
      expect(patch: "/users/1/change_password").to route_to(controller: "users", action: "change_password", id: "1")
    end

    it "doesn't recognize #change_password with non-numeric id" do
      expect(patch: "/users/aaron/change_password").not_to be_routable
    end
  end
end
