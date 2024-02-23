# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "opportunities/edit" do
  include OpportunitiesHelper

  before do
    login

    assign(:opportunity, @opportunity = build_stubbed(:opportunity, user: current_user))
    assign(:users, [current_user])
    assign(:account, @account = build_stubbed(:account))
    assign(:accounts, [@account])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "cancel from opportunity index page: should replace [Edit Opportunity] form with opportunity partial" do
    params[:cancel] = "true"

    render
    expect(rendered).to include("$('#opportunity_#{@opportunity.id}').replaceWith")
  end

  it "cancel from opportunity landing page: should hide [Edit Opportunity] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
    params[:cancel] = "true"

    render
    expect(rendered).to include("crm.flip_form('edit_opportunity'")
  end

  it "edit: should hide previously open [Edit Opportunity] for and replace it with opportunity partial" do
    params[:cancel] = nil
    assign(:previous, previous = build_stubbed(:opportunity, user: current_user))

    render
    expect(rendered).to include("$('#opportunity_#{previous.id}').replaceWith")
  end

  it "edit: remove previously open [Edit Opportunity] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    expect(rendered).to include("crm.flick('opportunity_#{previous}', 'remove');")
  end

  it "edit from opportunities index page: should turn off highlight, hide [Create Opportunity] form, and replace current opportunity with [Edit Opportunity] form" do
    params[:cancel] = nil

    render
    expect(rendered).to include("crm.highlight_off('opportunity_#{@opportunity.id}');")
    expect(rendered).to include("crm.hide_form('create_opportunity')")
    expect(rendered).to include("$('#opportunity_#{@opportunity.id}').html")
  end

  it "edit from opportunity landing page: should show [Edit Opportunity] form" do
    params[:cancel] = "false"

    render
    expect(rendered).to include("$('#edit_opportunity').html")
    expect(rendered).to include("crm.flip_form('edit_opportunity'")
  end

  it "edit: should handle new or existing account for the opportunity" do
    render
    expect(rendered).to include("crm.create_or_select_account")
  end
end
