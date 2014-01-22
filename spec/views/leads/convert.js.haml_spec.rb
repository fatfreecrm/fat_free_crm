# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/convert" do
  include LeadsHelper

  before do
    login_and_assign

    assign(:lead, @lead = FactoryGirl.create(:lead, :user => current_user))
    assign(:users, [ current_user ])
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
    assign(:opportunity, FactoryGirl.create(:opportunity))
  end

  it "cancel from lead index page: should replace [Convert Lead] form with lead partial" do
    params[:cancel] = "true"

    render
    rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
  end

  it "cancel from lead landing page: should hide [Convert Lead] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('convert_lead'")
  end

  it "convert: should hide previously open [Convert Lead] and replace it with lead partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.create(:lead, :user => current_user))

    render
    rendered.should include("$('#lead_#{previous.id}').replaceWith")
  end

  it "convert: should remove previously open [Convert Lead] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include("crm.flick('lead_#{previous}', 'remove');")
  end

  it "convert from leads index page: should turn off highlight, hide [Create Lead] form, and replace current lead with [Convert Lead] form" do
    params[:cancel] = nil

    render
    rendered.should include("crm.highlight_off('lead_#{@lead.id}');")
    rendered.should include("crm.hide_form('create_lead')")
    rendered.should include("$('#lead_#{@lead.id}').html")
  end

  it "convert from lead landing page: should hide [Edit Lead] and show [Convert Lead] form" do
    params[:cancel] = "false"

    render
    rendered.should include("#convert_lead")
    rendered.should include("crm.hide_form('edit_lead'")
    rendered.should include("crm.flip_form('convert_lead'")
  end

  it "convert: should handle new or existing account and set up calendar field" do
    params[:cancel] = "false"

    render
    rendered.should include("crm.create_or_select_account")
    rendered.should include('focus()')
  end

end
