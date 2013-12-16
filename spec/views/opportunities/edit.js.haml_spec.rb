# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/edit" do
  include OpportunitiesHelper

  before do
    login_and_assign

    assign(:opportunity, @opportunity = FactoryGirl.create(:opportunity, :user => current_user))
    assign(:users, [ current_user ])
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "cancel from opportunity index page: should replace [Edit Opportunity] form with opportunity partial" do
    params[:cancel] = "true"

    render
    rendered.should include("$('#opportunity_#{@opportunity.id}').replaceWith")
  end

  it "cancel from opportunity landing page: should hide [Edit Opportunity] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('edit_opportunity'")
  end

  it "edit: should hide previously open [Edit Opportunity] for and replace it with opportunity partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.create(:opportunity, :user => current_user))

    render
    rendered.should include("$('#opportunity_#{previous.id}').replaceWith")
  end

  it "edit: remove previously open [Edit Opportunity] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include("crm.flick('opportunity_#{previous}', 'remove');")
  end

  it "edit from opportunities index page: should turn off highlight, hide [Create Opportunity] form, and replace current opportunity with [Edit Opportunity] form" do
    params[:cancel] = nil

    render
    rendered.should include("crm.highlight_off('opportunity_#{@opportunity.id}');")
    rendered.should include("crm.hide_form('create_opportunity')")
    rendered.should include("$('#opportunity_#{@opportunity.id}').html")
  end

  it "edit from opportunity landing page: should show [Edit Opportunity] form" do
    params[:cancel] = "false"

    render
    rendered.should include("$('#edit_opportunity').html")
    rendered.should include("crm.flip_form('edit_opportunity'")
  end

  it "edit: should handle new or existing account for the opportunity" do

    render
    rendered.should include("crm.create_or_select_account")
  end

end
