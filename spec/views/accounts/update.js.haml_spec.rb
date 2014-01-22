# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/update" do
  include AccountsHelper

  before do
    login_and_assign

    assign(:account, @account = FactoryGirl.create(:account, :user => current_user))
    assign(:users, [ current_user ])
    assign(:account_category_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on account landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should flip [edit_account] form" do
        render
        rendered.should_not include("account_#{@account.id}")
        rendered.should include("crm.flip_form('edit_account'")
      end

      it "should update sidebar" do
        render
        rendered.should include("$('#sidebar').html")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#summary').effect('shake'")
      end
    end

    describe "on accounts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Account Categories")
        rendered.should have_text("Recent Items")
      end

      it "should replace [edit_account] form with account partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
        render

        rendered.should include("#account_#{@account.id}")
        rendered.should include(%Q/$('#account_#{@account.id}').effect("highlight"/)
      end
    end
  end # no errors

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

        rendered.should include("#edit_account")
        rendered.should include(%Q/$('#edit_account').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on accounts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        rendered.should include("account_#{@account.id}")
        rendered.should include(%Q/$('#account_#{@account.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
