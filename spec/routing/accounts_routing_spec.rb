# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe AccountsController do
    describe "routing" do
      it "recognizes and generates #index" do
        expect(get: "fat_free_crm/accounts").to route_to(controller: "fat_free_crm/accounts", action: "index")
      end

      it "recognizes and generates #new" do
        expect(get: "fat_free_crm/accounts/new").to route_to(controller: "fat_free_crm/accounts", action: "new")
      end

      it "recognizes and generates #show" do
        expect(get: "fat_free_crm/accounts/1").to route_to(controller: "fat_free_crm/accounts", action: "show", id: "1")
      end

      it "doesn't recognize #show with non-numeric id" do
        expect(get: "fat_free_crm/accounts/aaron").not_to be_routable
      end

      it "recognizes and generates #edit" do
        expect(get: "fat_free_crm/accounts/1/edit").to route_to(controller: "fat_free_crm/accounts", action: "edit", id: "1")
      end

      it "doesn't recognize #edit with non-numeric id" do
        expect(get: "fat_free_crm/accounts/aaron/edit").not_to be_routable
      end

      it "recognizes and generates #create" do
        expect(post: "fat_free_crm/accounts").to route_to(controller: "fat_free_crm/accounts", action: "create")
      end

      it "recognizes and generates #update" do
        expect(put: "fat_free_crm/accounts/1").to route_to(controller: "fat_free_crm/accounts", action: "update", id: "1")
      end

      it "doesn't recognize #update with non-numeric id" do
        expect(put: "fat_free_crm/accounts/aaron").not_to be_routable
      end

      it "recognizes and generates #destroy" do
        expect(delete: "fat_free_crm/accounts/1").to route_to(controller: "fat_free_crm/accounts", action: "destroy", id: "1")
      end

      it "doesn't recognize #destroy with non-numeric id" do
        expect(delete: "fat_free_crm/accounts/aaron").not_to be_routable
      end

      it "recognizes and generates #auto_complete" do
        expect(get: "fat_free_crm/accounts/auto_complete").to route_to(controller: "fat_free_crm/accounts", action: "auto_complete")
      end
    end
  end
end
