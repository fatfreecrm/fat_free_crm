# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/update" do
  include ContactsHelper

  before do
    login

    assign(:contact, @contact = build_stubbed(:contact, user: current_user))
    assign(:users, [current_user])
    assign(:account, @account = build_stubbed(:account))
    assign(:accounts, [@account])
  end

  describe "no errors:" do
    describe "on contact landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
      end

      it "should flip [edit_contact] form" do
        render
        expect(rendered).not_to include("contact_#{@contact.id}")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to include("$('#summary').effect('shake'")
      end
    end

    describe "on contacts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      end

      it "should replace [Edit Contact] with contact partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"

        render
        expect(rendered).to include("$('#contact_#{@contact.id}').replaceWith('<li class=\\'contact highlight\\' id=\\'contact_#{@contact.id}\\'")
        expect(rendered).to include(%/$('#contact_#{@contact.id}').effect("highlight"/)
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should replace [Edit Contact] with contact partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"

        render
        expect(rendered).to include("$('#contact_#{@contact.id}').replaceWith('<li class=\\'contact highlight\\' id=\\'contact_#{@contact.id}\\'")
        expect(rendered).to include(%/$('#contact_#{@contact.id}').effect("highlight"/)
      end

      it "should update recently viewed items" do
        render
        expect(rendered).to include("#recently")
      end
    end
  end

  describe "validation errors:" do
    before do
      @contact.errors.add(:first_name)
    end

    describe "on contact landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        expect(rendered).to include("$('#edit_contact').html")
        expect(rendered).to include('crm.create_or_select_account(false)')
        expect(rendered).to include(%/$('#edit_contact').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end

    describe "on contacts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        expect(rendered).to include("$('#contact_#{@contact.id}').html")
        expect(rendered).to include('crm.create_or_select_account(false)')
        expect(rendered).to include(%/$('#contact_#{@contact.id}').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "errors: should show disabled accounts dropdown" do
        render
        expect(rendered).to include("crm.create_or_select_account(#{@referer =~ /\/accounts\//})")
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        expect(rendered).to include("$('#contact_#{@contact.id}').html")
        expect(rendered).to include(%/$('#contact_#{@contact.id}').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end
  end
end
