# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/new" do
  include ContactsHelper

  before do
    login_and_assign
    @account = FactoryGirl.build_stubbed(:account)
    assign(:contact, Contact.new(user: current_user))
    assign(:users, [current_user])
    assign(:account, @account)
    assign(:accounts, [@account])
  end

  it "should toggle empty message div if it exists" do
    render

    expect(rendered).to include("crm.flick('empty', 'toggle')")
  end

  describe "new contact" do
    it "should render [new] template into :create_contact div" do
      params[:cancel] = nil
      render

      expect(rendered).to include("$('#create_contact').html")
      expect(rendered).to include("crm.create_or_select_account(false)")
    end
  end

  describe "cancel new contact" do
    it "should hide [create contact] form" do
      params[:cancel] = "true"
      render

      expect(rendered).not_to include("$('#create_contact').html")
      expect(rendered).to include("crm.flip_form('create_contact');")
    end
  end
end
