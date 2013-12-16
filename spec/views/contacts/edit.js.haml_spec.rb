# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/edit" do
  include ContactsHelper

  before do
    login_and_assign
    assign(:contact, @contact = FactoryGirl.create(:contact, :user => current_user))
    assign(:users, [ current_user ])
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
  end

  it "cancel from contact index page: should replace [Edit Contact] form with contact partial" do
    params[:cancel] = "true"

    render
    rendered.should include("$('#contact_#{@contact.id}').replaceWith('<li class=\\'contact highlight\\' id=\\'contact_#{@contact.id}\\'")
  end

  it "cancel from contact landing page: should hide [Edit Contact] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('edit_contact'")
  end

  it "edit: should hide previously open [Edit Contact] for and replace it with contact partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.create(:contact, :user => current_user))

    render
    rendered.should include("$('#contact_#{previous.id}').replaceWith")
  end

  it "edit: should hide and remove previously open [Edit Contact] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include("crm.flick('contact_#{previous}', 'remove');")
  end

  it "edit from contacts index page: should turn off highlight, hide [Create Contact] form, and replace current contact with [Edit Contact] form" do
    params[:cancel] = nil

    render
    rendered.should include("crm.highlight_off('contact_#{@contact.id}');")
    rendered.should include("crm.hide_form('create_contact')")
    rendered.should include("$('#contact_#{@contact.id}').html")
    rendered.should include("crm.create_or_select_account(false)")
  end

  it "edit from contact landing page: should show [Edit Contact] form" do
    params[:cancel] = "false"

    render
    rendered.should include("$('#edit_contact').html")
    rendered.should include("crm.flip_form('edit_contact'")
  end

  it "should show handle new or existing account for the contact" do

    render
    rendered.should include("crm.create_or_select_account(false)")
  end

end
