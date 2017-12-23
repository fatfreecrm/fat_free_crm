# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect(get: "/opportunities").to route_to(controller: "opportunities", action: "index")
    end

    it "recognizes and generates #new" do
      expect(get: "/opportunities/new").to route_to(controller: "opportunities", action: "new")
    end

    it "recognizes and generates #show" do
      expect(get: "/opportunities/1").to route_to(controller: "opportunities", action: "show", id: "1")
    end

    it "doesn't recognize #show with non-numeric id" do
      expect(get: "/opportunities/aaron").not_to be_routable
    end

    it "recognizes and generates #edit" do
      expect(get: "/opportunities/1/edit").to route_to(controller: "opportunities", action: "edit", id: "1")
    end

    it "doesn't recognize #edit with non-numeric id" do
      expect(get: "/opportunities/aaron/edit").not_to be_routable
    end

    it "recognizes and generates #create" do
      expect(post: "/opportunities").to route_to(controller: "opportunities", action: "create")
    end

    it "recognizes and generates #update" do
      expect(put: "/opportunities/1").to route_to(controller: "opportunities", action: "update", id: "1")
    end

    it "doesn't recognize #update with non-numeric id" do
      expect(put: "/opportunities/aaron").not_to be_routable
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/opportunities/1").to route_to(controller: "opportunities", action: "destroy", id: "1")
    end

    it "doesn't recognize #destroy with non-numeric id" do
      expect(delete: "/opportunities/aaron").not_to be_routable
    end

    it "recognizes and generates #auto_complete" do
      expect(get: "/opportunities/auto_complete").to route_to(controller: "opportunities", action: "auto_complete")
    end

    it "recognizes and generates #filter" do
      expect(post: "/opportunities/filter").to route_to(controller: "opportunities", action: "filter")
    end
  end
end
