# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/edit" do
  include LeadsHelper

  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead, :status => "new", :user => current_user))
    assign(:users, [ current_user ])
    assign(:campaigns, [ FactoryGirl.create(:campaign) ])
  end

  it "cancel from lead index page: should replace [Edit Lead] form with lead partial" do
    params[:cancel] = "true"

    render
    rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
  end

  it "cancel from lead landing page: should hide [Edit Lead] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('edit_lead'")
  end

  it "edit: should hide previously open [Edit Lead] and replace it with lead partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.create(:lead, :user => current_user))

    render
    rendered.should include("$('#lead_#{previous.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{previous.id}\\'")
  end

  it "edit: should remove previously open [Edit Lead] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include("crm.flick('lead_#{previous}', 'remove');")
  end

  it "edit from leads index page: should turn off highlight, hide [Create Lead] form, and replace current lead with [Edit Lead] form" do
    params[:cancel] = nil

    render
    rendered.should include("crm.highlight_off('lead_#{@lead.id}');")
    rendered.should include("crm.hide_form('create_lead')")
    rendered.should include("$('#lead_#{@lead.id}').html")
  end

  it "edit from lead landing page: should hide [Convert Lead] and show [Edit Lead] form" do
    params[:cancel] = "false"

    render
    rendered.should include("$('#edit_lead').html")
    rendered.should include("crm.hide_form('convert_lead'")
    rendered.should include("crm.flip_form('edit_lead'")
  end

  it "edit from lead landing page: should not attempt to hide [Convert Lead] if the lead is already converted" do
    params[:cancel] = "false"
    assign(:lead, FactoryGirl.create(:lead, :status => "converted", :user => current_user))

    render
    rendered.should_not include("crm.hide_form('convert_lead'")
  end

end
