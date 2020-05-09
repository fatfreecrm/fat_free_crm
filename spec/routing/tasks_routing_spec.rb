# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe TasksController do
    describe "routing" do
      it "recognizes and generates #index" do
        expect(get: "fat_free_crm/tasks").to route_to(controller: "fat_free_crm/tasks", action: "index")
      end

      it "recognizes and generates #new" do
        expect(get: "fat_free_crm/tasks/new").to route_to(controller: "fat_free_crm/tasks", action: "new")
      end

      it "recognizes and generates #show" do
        expect(get: "fat_free_crm/tasks/1").to route_to(controller: "fat_free_crm/tasks", action: "show", id: "1")
      end

      it "doesn't recognize #show with non-numeric id" do
        expect(get: "fat_free_crm/tasks/aaron").not_to be_routable
      end

      it "recognizes and generates #edit" do
        expect(get: "fat_free_crm/tasks/1/edit").to route_to(controller: "fat_free_crm/tasks", action: "edit", id: "1")
      end

      it "doesn't recognize #edit with non-numeric id" do
        expect(get: "fat_free_crm/tasks/aaron/edit").not_to be_routable
      end

      it "recognizes and generates #create" do
        expect(post: "fat_free_crm/tasks").to route_to(controller: "fat_free_crm/tasks", action: "create")
      end

      it "recognizes and generates #update" do
        expect(put: "fat_free_crm/tasks/1").to route_to(controller: "fat_free_crm/tasks", action: "update", id: "1")
      end

      it "doesn't recognize #update with non-numeric id" do
        expect(put: "fat_free_crm/tasks/aaron").not_to be_routable
      end

      it "recognizes and generates #destroy" do
        expect(delete: "fat_free_crm/tasks/1").to route_to(controller: "fat_free_crm/tasks", action: "destroy", id: "1")
      end

      it "doesn't recognize #destroy with non-numeric id" do
        expect(delete: "fat_free_crm/tasks/aaron").not_to be_routable
      end

      it "recognizes and generates #filter" do
        expect(post: "fat_free_crm/tasks/filter").to route_to(controller: "fat_free_crm/tasks", action: "filter")
      end

      it "should generate params for #complete" do
        expect(put: "fat_free_crm/tasks/1/complete").to route_to(controller: "fat_free_crm/tasks", action: "complete", id: "1")
      end

      it "doesn't recognize #complete with non-numeric id" do
        expect(put: "fat_free_crm/tasks/aaron/complete").not_to be_routable
      end
    end
  end
end
