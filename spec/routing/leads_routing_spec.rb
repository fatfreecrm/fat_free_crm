# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect(get: "/leads").to route_to(controller: "leads", action: "index")
    end

    it "recognizes and generates #new" do
      expect(get: "/leads/new").to route_to(controller: "leads", action: "new")
    end

    it "recognizes and generates #show" do
      expect(get: "/leads/1").to route_to(controller: "leads", action: "show", id: "1")
    end

    it "doesn't recognize #show with non-numeric id" do
      expect(get: "/leads/aaron").not_to be_routable
    end

    it "recognizes and generates #edit" do
      expect(get: "/leads/1/edit").to route_to(controller: "leads", action: "edit", id: "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      expect(get: "/leads/aaron/edit").not_to be_routable
    end

    it "recognizes and generates #create" do
      expect(post: "/leads").to route_to(controller: "leads", action: "create")
    end

    it "recognizes and generates #update" do
      expect(put: "/leads/1").to route_to(controller: "leads", action: "update", id: "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      expect(put: "/leads/aaron").not_to be_routable
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/leads/1").to route_to(controller: "leads", action: "destroy", id: "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      expect(delete: "/leads/aaron").not_to be_routable
    end

    it "recognizes and generates #auto_complete" do
      expect(get: "/leads/auto_complete").to route_to(controller: "leads", action: "auto_complete")
    end

    it "recognizes and generates #filter" do
      expect(post: "/leads/filter").to route_to(controller: "leads", action: "filter")
    end

    it "should generate params for #convert" do
      expect(get: "/leads/1/convert").to route_to(controller: "leads", action: "convert", id: "1")
    end

    it "doesn't recognize #convert with non-numeric id" do
      expect(get: "/leads/aaron/convert").not_to be_routable
    end

    it "should generate params for #promote" do
      expect(put: "/leads/1/promote").to route_to(controller: "leads", action: "promote", id: "1")
    end

    it "doesn't recognize #promote with non-numeric id" do
      expect(put: "/leads/aaron/promote").not_to be_routable
    end

    it "should generate params for #reject" do
      expect(put: "/leads/1/reject").to route_to(controller: "leads", action: "reject", id: "1")
    end

    it "doesn't recognize #reject with non-numeric id" do
      expect(put: "/leads/aaron/reject").not_to be_routable
    end
  end
end
