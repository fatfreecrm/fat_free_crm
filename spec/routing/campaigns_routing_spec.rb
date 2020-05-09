# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe CampaignsController do
    describe "routing" do
      it "recognizes and generates #index" do
        expect(get: "fat_free_crm/campaigns").to route_to(controller: "fat_free_crm/campaigns", action: "index")
      end

      it "recognizes and generates #new" do
        expect(get: "fat_free_crm/campaigns/new").to route_to(controller: "fat_free_crm/campaigns", action: "new")
      end

      it "recognizes and generates #show" do
        expect(get: "fat_free_crm/campaigns/1").to route_to(controller: "fat_free_crm/campaigns", action: "show", id: "1")
      end

      it "doesn't recognize #show with non-numeric id" do
        expect(get: "fat_free_crm/campaigns/aaron").not_to be_routable
      end

      it "recognizes and generates #edit" do
        expect(get: "fat_free_crm/campaigns/1/edit").to route_to(controller: "fat_free_crm/campaigns", action: "edit", id: "1")
      end

      it "doesn't recognize #edit with non-numeric id" do
        expect(get: "fat_free_crm/campaigns/aaron/edit").not_to be_routable
      end

      it "recognizes and generates #create" do
        expect(post: "fat_free_crm/campaigns").to route_to(controller: "fat_free_crm/campaigns", action: "create")
      end

      it "recognizes and generates #update" do
        expect(put: "fat_free_crm/campaigns/1").to route_to(controller: "fat_free_crm/campaigns", action: "update", id: "1")
      end

      it "doesn't recognize #update with non-numeric id" do
        expect(put: "fat_free_crm/campaigns/aaron").not_to be_routable
      end

      it "recognizes and generates #destroy" do
        expect(delete: "fat_free_crm/campaigns/1").to route_to(controller: "fat_free_crm/campaigns", action: "destroy", id: "1")
      end

      it "doesn't recognize #destroy with non-numeric id" do
        expect(delete: "fat_free_crm/campaigns/aaron").not_to be_routable
      end

      it "recognizes and generates #auto_complete" do
        expect(get: "fat_free_crm/campaigns/auto_complete").to route_to(controller: "fat_free_crm/campaigns", action: "auto_complete")
      end

      it "recognizes and generates #filter" do
        expect(post: "fat_free_crm/campaigns/filter").to route_to(controller: "fat_free_crm/campaigns", action: "filter")
      end
    end
  end
end
