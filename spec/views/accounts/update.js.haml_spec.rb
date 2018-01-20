# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/update" do
  include AccountsHelper

  before do
    login

    assign(:account, @account = build_stubbed(:account, user: current_user))
    assign(:users, [current_user])
    assign(:account_category_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on account landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should flip [edit_account] form" do
        render
        expect(rendered).not_to include("account_#{@account.id}")
        expect(rendered).to include("crm.flip_form('edit_account'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("$('#sidebar').html")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to include("$('#summary').effect('shake'")
      end
    end

    describe "on accounts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Account Categories")
        expect(rendered).to have_text("Recent Items")
      end

      it "should replace [edit_account] form with account partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
        render

        expect(rendered).to include("#account_#{@account.id}")
        expect(rendered).to include(%/$('#account_#{@account.id}').effect("highlight"/)
      end
    end
  end

  describe "validation errors:" do
    before do
      @account.errors.add(:name)
    end

    describe "on account landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        expect(rendered).to include("#edit_account")
        expect(rendered).to include(%/$('#edit_account').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end

    describe "on accounts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        expect(rendered).to include("account_#{@account.id}")
        expect(rendered).to include(%/$('#account_#{@account.id}').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end
  end
end
