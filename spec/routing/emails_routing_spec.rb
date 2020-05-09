# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe EmailsController do
    describe "routing" do
      it "should not recognize #index" do
        expect(get: "fat_free_crm/emails").not_to be_routable
      end

      it "should not recognize #new" do
        expect(get: "fat_free_crm/emails/new").not_to be_routable
      end

      it "should not recognize #show" do
        expect(get: "fat_free_crm/emails/1").not_to be_routable
      end

      it "should not recognize #edit" do
        expect(get: "fat_free_crm/emails/1/edit").not_to be_routable
      end

      it "should not recognize #create" do
        expect(post: "fat_free_crm/emails").not_to be_routable
      end

      it "should not recognize #update" do
        expect(put: "fat_free_crm/emails/1").not_to be_routable
      end

      it "recognizes and generates #destroy" do
        expect(delete: "fat_free_crm/emails/1").to route_to(controller: "fat_free_crm/emails", action: "destroy", id: "1")
      end
    end
  end
end
