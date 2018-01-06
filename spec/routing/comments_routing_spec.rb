# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect(get: "/comments").to route_to(controller: "comments", action: "index")
    end

    it "recognizes and generates #edit" do
      expect(get: "/comments/1/edit").to route_to(controller: "comments", action: "edit", id: "1")
    end

    it "recognizes and generates #create" do
      expect(post: "/comments").to route_to(controller: "comments", action: "create")
    end

    it "recognizes and generates #update" do
      expect(put: "/comments/1").to route_to(controller: "comments", action: "update", id: "1")
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/comments/1").to route_to(controller: "comments", action: "destroy", id: "1")
    end
  end
end
