# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe EmailsController do
  describe "routing" do
    it "should not recognize #index" do
      expect(get: "/emails").not_to be_routable
    end

    it "should not recognize #new" do
      expect(get: "/emails/new").not_to be_routable
    end

    it "should not recognize #show" do
      expect(get: "/emails/1").not_to be_routable
    end

    it "should not recognize #edit" do
      expect(get: "/emails/1/edit").not_to be_routable
    end

    it "should not recognize #create" do
      expect(post: "/emails").not_to be_routable
    end

    it "should not recognize #update" do
      expect(put: "/emails/1").not_to be_routable
    end

    it "recognizes and generates #destroy" do
      expect(delete: "/emails/1").to route_to(controller: "emails", action: "destroy", id: "1")
    end
  end
end
