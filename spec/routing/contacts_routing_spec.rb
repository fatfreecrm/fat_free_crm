# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe ContactsController do
    describe "routing" do
      it "recognizes and generates #index" do
        expect(get: "fat_free_crm/contacts").to route_to(controller: "fat_free_crm/contacts", action: "index")
      end

      it "recognizes and generates #new" do
        expect(get: "fat_free_crm/contacts/new").to route_to(controller: "fat_free_crm/contacts", action: "new")
      end

      it "recognizes and generates #show" do
        expect(get: "fat_free_crm/contacts/1").to route_to(controller: "fat_free_crm/contacts", action: "show", id: "1")
      end

      it "doesn't recognize #show with non-numeric id" do
        expect(get: "fat_free_crm/contacts/aaron").not_to be_routable
      end

      it "recognizes and generates #edit" do
        expect(get: "fat_free_crm/contacts/1/edit").to route_to(controller: "fat_free_crm/contacts", action: "edit", id: "1")
      end

      it "doesn't recognize #edit with non-numeric id" do
        expect(get: "fat_free_crm/campaigns/aaron/edit").not_to be_routable
      end

      it "recognizes and generates #create" do
        expect(post: "fat_free_crm/contacts").to route_to(controller: "fat_free_crm/contacts", action: "create")
      end

      it "recognizes and generates #update" do
        expect(put: "fat_free_crm/contacts/1").to route_to(controller: "fat_free_crm/contacts", action: "update", id: "1")
      end

      it "doesn't recognize #update with non-numeric id" do
        expect(put: "fat_free_crm/campaigns/aaron").not_to be_routable
      end

      it "recognizes and generates #destroy" do
        expect(delete: "fat_free_crm/contacts/1").to route_to(controller: "fat_free_crm/contacts", action: "destroy", id: "1")
      end

      it "doesn't recognize #delete with non-numeric id" do
        expect(delete: "fat_free_crm/campaigns/aaron").not_to be_routable
      end

      it "recognizes and generates #auto_complete" do
        expect(get: "fat_free_crm/contacts/auto_complete").to route_to(controller: "fat_free_crm/contacts", action: "auto_complete")
      end
    end
  end
end
