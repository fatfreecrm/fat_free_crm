# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CampaignsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect(get: "/campaigns").to route_to(controller: "campaigns", action: "index")
    end

    it "recognizes and generates #new" do
      expect(get: "/campaigns/new").to route_to(controller: "campaigns", action: "new")
    end

    it "recognizes and generates #show" do
      expect(get: "/campaigns/1").to route_to(controller: "campaigns", action: "show", id: "1")
    end

    it "doesn't recognize #show with non-numeric id" do
      expect(get: "/campaigns/aaron").not_to be_routable
    end

    it "recognizes and generates #edit" do
      expect(get: "/campaigns/1/edit").to route_to(controller: "campaigns", action: "edit", id: "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      expect(get: "/campaigns/aaron/edit").not_to be_routable
    end

    it "recognizes and generates #create" do
      expect(post: "/campaigns").to route_to(controller: "campaigns", action: "create")
    end

    it "recognizes and generates #update" do
      expect(put: "/campaigns/1").to route_to(controller: "campaigns", action: "update", id: "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      expect(put: "/campaigns/aaron").not_to be_routable
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/campaigns/1").to route_to(controller: "campaigns", action: "destroy", id: "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      expect(delete: "/campaigns/aaron").not_to be_routable
    end

    it "recognizes and generates #auto_complete" do
      expect(get: "/campaigns/auto_complete").to route_to(controller: "campaigns", action: "auto_complete")
    end

    it "recognizes and generates #filter" do
      expect(post: "/campaigns/filter").to route_to(controller: "campaigns", action: "filter")
    end
  end
end
