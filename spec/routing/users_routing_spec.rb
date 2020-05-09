# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe UsersController do
    describe "routing" do
      it "recognizes #index" do
        expect(get: "fat_free_crm/users").to route_to(controller: "fat_free_crm/users", action: "index")
      end

      it "recognizes and generates Devise registrations routes" do
        expect(get: "fat_free_crm/users/sign_up").to route_to(controller: "fat_free_crm/registrations", action: "new")
        expect(get: "fat_free_crm/users/edit").to route_to(controller: "fat_free_crm/registrations", action: "edit")
        expect(get: "fat_free_crm/users/cancel").to route_to(controller: "fat_free_crm/registrations", action: "cancel")
        expect(post: "fat_free_crm/users").to route_to(controller: "fat_free_crm/registrations", action: "create")
        expect(put: "fat_free_crm/users").to route_to(controller: "fat_free_crm/registrations", action: "update")
        expect(patch: "fat_free_crm/users").to route_to(controller: "fat_free_crm/registrations", action: "update")
        expect(delete: "fat_free_crm/users").to route_to(controller: "fat_free_crm/registrations", action: "destroy")
      end

      it "recognizes and generates Devise sessions routes" do
        expect(get: "fat_free_crm/users/sign_in").to route_to(controller: "fat_free_crm/sessions", action: "new")
        expect(post: "fat_free_crm/users/sign_in").to route_to(controller: "fat_free_crm/sessions", action: "create")
        expect(delete: "fat_free_crm/users/sign_out").to route_to(controller: "fat_free_crm/sessions", action: "destroy")
      end

      it "recognizes and generates Devise passwords routes" do
        expect(get: "fat_free_crm/users/password/new").to route_to(controller: "fat_free_crm/passwords", action: "new")
        expect(get: "fat_free_crm/users/password/edit").to route_to(controller: "fat_free_crm/passwords", action: "edit")
        expect(post: "fat_free_crm/users/password").to route_to(controller: "fat_free_crm/passwords", action: "create")
        expect(put: "fat_free_crm/users/password").to route_to(controller: "fat_free_crm/passwords", action: "update")
        expect(patch: "fat_free_crm/users/password").to route_to(controller: "fat_free_crm/passwords", action: "update")
      end

      it "recognizes and generates Devise confirmations routes" do
        expect(get: "fat_free_crm/users/confirmation/new").to route_to(controller: "fat_free_crm/confirmations", action: "new")
        expect(get: "fat_free_crm/users/confirmation").to route_to(controller: "fat_free_crm/confirmations", action: "show")
        expect(post: "fat_free_crm/users/confirmation").to route_to(controller: "fat_free_crm/confirmations", action: "create")
      end

      it "recognizes and generates #show as /profile" do
        expect(get: "fat_free_crm/profile").to route_to(controller: "fat_free_crm/users", action: "show")
      end

      it "recognizes and generates #edit" do
        expect(get: "fat_free_crm/users/1/edit").to route_to(controller: "fat_free_crm/users", action: "edit", id: "1")
      end

      it "doesn't recognize #edit with non-numeric id" do
        expect(get: "fat_free_crm/users/aaron/edit").not_to be_routable
      end

      it "recognizes and generates #update" do
        expect(put: "fat_free_crm/users/1").to route_to(controller: "fat_free_crm/users", action: "update", id: "1")
      end

      it "doesn't recognize #update with non-numeric id" do
        expect(put: "fat_free_crm/users/aaron").not_to be_routable
      end

      it "doesn't recognize #destroy" do
        expect(delete: "fat_free_crm/users/1").not_to be_routable
      end

      it "doesn't recognize #destroy with non-numeric id" do
        expect(delete: "fat_free_crm/users/aaron").not_to be_routable
      end

      it "should generate params for #avatar" do
        expect(get: "fat_free_crm/users/1/avatar").to route_to(controller: "fat_free_crm/users", action: "avatar", id: "1")
      end

      it "doesn't recognize #avatar with non-numeric id" do
        expect(get: "fat_free_crm/users/aaron/avatar").not_to be_routable
      end

      it "should generate params for #upload_avatar" do
        expect(put: "fat_free_crm/users/1/upload_avatar").to route_to(controller: "fat_free_crm/users", action: "upload_avatar", id: "1")
      end

      it "doesn't recognize #upload_avatar with non-numeric id" do
        expect(put: "fat_free_crm/users/aaron/upload_avatar").not_to be_routable
      end

      it "should generate params for #password" do
        expect(get: "fat_free_crm/users/1/password").to route_to(controller: "fat_free_crm/users", action: "password", id: "1")
      end

      it "doesn't recognize #password with non-numeric id" do
        expect(get: "fat_free_crm/users/aaron/password").not_to be_routable
      end

      it "should generate params for #change_password" do
        expect(patch: "fat_free_crm/users/1/change_password").to route_to(controller: "fat_free_crm/users", action: "change_password", id: "1")
      end

      it "doesn't recognize #change_password with non-numeric id" do
        expect(patch: "fat_free_crm/users/aaron/change_password").not_to be_routable
      end
    end
  end
end
