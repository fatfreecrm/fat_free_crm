# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/update" do
  include ContactsHelper

  before do
    login_and_assign

    assign(:contact, @contact = FactoryGirl.create(:contact, :user => current_user))
    assign(:users, [ current_user ])
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
  end

  describe "no errors:" do
    describe "on contact landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
      end

      it "should flip [edit_contact] form" do
        render
        rendered.should_not include("contact_#{@contact.id}")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#summary').effect('shake'")
      end
    end

    describe "on contacts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      end

      it "should replace [Edit Contact] with contact partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"

        render
        rendered.should include("$('#contact_#{@contact.id}').replaceWith('<li class=\\'contact highlight\\' id=\\'contact_#{@contact.id}\\'")
        rendered.should include(%Q/$('#contact_#{@contact.id}').effect("highlight"/)
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Recent Items")
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should replace [Edit Contact] with contact partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"

        render
        rendered.should include("$('#contact_#{@contact.id}').replaceWith('<li class=\\'contact highlight\\' id=\\'contact_#{@contact.id}\\'")
        rendered.should include(%Q/$('#contact_#{@contact.id}').effect("highlight"/)
      end

      it "should update recently viewed items" do
        render
        rendered.should include("#recently")
      end
    end
  end # no errors

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
        rendered.should include("$('#edit_contact').html")
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include(%Q/$('#edit_contact').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on contacts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        rendered.should include("$('#contact_#{@contact.id}').html")
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include(%Q/$('#contact_#{@contact.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "errors: should show disabled accounts dropdown" do
        render
        rendered.should include("crm.create_or_select_account(#{@referer =~ /\/accounts\//})")
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        rendered.should include("$('#contact_#{@contact.id}').html")
        rendered.should include(%Q/$('#contact_#{@contact.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
