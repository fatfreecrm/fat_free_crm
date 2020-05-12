# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/contacts/create" do

    before do
      view.extend FatFreeCrm::AccountsHelper
      view.extend FatFreeCrm::AddressesHelper
      login
    end

    describe "create success" do
      before do
        assign(:contact, @contact = build_stubbed(:contact))
        assign(:contacts, [@contact].paginate)
      end

      it "should hide [Create Contact] form and insert contact partial" do
        render

        expect(rendered).to include("$('#contacts').prepend('<li class=\\'brief fat_free_crm_contact highlight\\' id=\\'fat_free_crm_contact_#{@contact.id}\\'")
        expect(rendered).to include(%/$('#contact_#{@contact.id}').effect("highlight"/)
      end

      it "should refresh sidebar when called from contacts index" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/fat_free_crm/contacts"
        render

        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
      end

      it "should update pagination when called from contacts index" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/fat_free_crm/contacts"
        render

        expect(rendered).to include("#paginate")
      end

      it "should update recently viewed items when called from related asset" do
        render

        expect(rendered).to include("#recently")
      end
    end

    describe "create failure" do
      it "create (failure): should re-render [create] template in :create_contact div" do
        assign(:contact, build(:contact, first_name: nil)) # make it invalid
        @account = build_stubbed(:account)
        assign(:users, [build_stubbed(:user)])
        assign(:account, @account)
        assign(:accounts, [@account])

        render

        expect(rendered).to include("$('#create_contact').html")
        expect(rendered).to include(%/$('#create_contact').effect("shake"/)
      end
    end
  end
end