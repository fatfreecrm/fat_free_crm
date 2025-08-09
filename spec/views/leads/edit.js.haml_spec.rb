# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "leads/edit" do
  include LeadsHelper

  before do
    login
    assign(:lead, @lead = build_stubbed(:lead, status: "new", user: current_user))
    assign(:users, [current_user])
    assign(:campaigns, [build_stubbed(:campaign)])
  end

  it "cancel from lead index page: should replace [Edit Lead] form with lead partial" do
    params[:cancel] = "true"

    render
    expect(rendered).to include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
  end

  it "cancel from lead landing page: should hide [Edit Lead] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
    params[:cancel] = "true"

    render
    expect(rendered).to include("crm.flip_form('edit_lead'")
  end

  it "edit: should hide previously open [Edit Lead] and replace it with lead partial" do
    params[:cancel] = nil
    assign(:previous, previous = build_stubbed(:lead, user: current_user))

    render
    expect(rendered).to include("$('#lead_#{previous.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{previous.id}\\'")
  end

  it "edit: should remove previously open [Edit Lead] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    expect(rendered).to include("crm.flick('lead_#{previous}', 'remove');")
  end

  it "edit from leads index page: should turn off highlight, hide [Create Lead] form, and replace current lead with [Edit Lead] form" do
    params[:cancel] = nil

    render
    expect(rendered).to include("crm.highlight_off('lead_#{@lead.id}');")
    expect(rendered).to include("crm.hide_form('create_lead')")
    expect(rendered).to include("$('#lead_#{@lead.id}').html")
  end

  it "edit from lead landing page: should hide [Convert Lead] and show [Edit Lead] form" do
    params[:cancel] = "false"

    render
    expect(rendered).to include("$('#edit_lead').html")
    expect(rendered).to include("crm.hide_form('convert_lead'")
    expect(rendered).to include("crm.flip_form('edit_lead'")
  end

  it "edit from lead landing page: should not attempt to hide [Convert Lead] if the lead is already converted" do
    params[:cancel] = "false"
    assign(:lead, build_stubbed(:lead, status: "converted", user: current_user))

    render
    expect(rendered).not_to include("crm.hide_form('convert_lead'")
  end
end
