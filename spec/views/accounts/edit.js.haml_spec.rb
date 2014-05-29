# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/edit" do
  include AccountsHelper

  before do
    login
    assign(:account, @account = FactoryGirl.create(:account, :user => current_user))
    assign(:users, [ current_user ])
  end

  it "cancel from accounts index page: should replace [Edit Account] form with account partial" do
    params[:cancel] = "true"

    render
    rendered.should include("account_#{@account.id}")
  end

  it "cancel from account landing page: should hide [Edit Account] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('edit_account'")
  end

  it "edit: should hide previously open [Edit Account] for and replace it with account partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.create(:account, :user => current_user))

    render
    rendered.should include("account_#{previous.id}")
  end

  it "edit: should remove previously open [Edit Account] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include("crm.flick('account_#{previous}', 'remove');")
  end

  it "edit from accounts index page: should turn off highlight, hide [Create Account] form, and replace current account with [edit account] form" do
    params[:cancel] = nil

    render
    rendered.should include("crm.highlight_off('account_#{@account.id}');")
    rendered.should include("crm.hide_form('create_account')")
    rendered.should include("account_#{@account.id}")
  end

  it "edit from account landing page: should show [edit account] form" do
    params[:cancel] = "false"

    render
    rendered.should include("edit_account")
    rendered.should include("crm.flip_form('edit_account'")
  end

end
