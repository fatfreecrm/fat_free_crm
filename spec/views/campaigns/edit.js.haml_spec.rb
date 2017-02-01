# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/edit" do
  include CampaignsHelper

  before do
    login_and_assign
    assign(:campaign, @campaign = FactoryGirl.build_stubbed(:campaign, user: current_user))
    assign(:users, [current_user])
  end

  it "cancel from campaign index page: should replace [Edit Campaign] form with campaign partial" do
    params[:cancel] = "true"

    render
    expect(rendered).to include("$('#campaign_#{@campaign.id}').replaceWith('<li class=\\'campaign highlight\\' id=\\'campaign_#{@campaign.id}\\'")
  end

  it "cancel from campaign landing page: should hide [Edit Campaign] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
    params[:cancel] = "true"

    render
    expect(rendered).to include("crm.flip_form('edit_campaign'")
  end

  it "edit: should hide previously open [Edit Campaign] for and replace it with campaign partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.build_stubbed(:campaign, user: current_user))

    render
    expect(rendered).to include("$('#campaign_#{previous.id}').replaceWith('<li class=\\'campaign highlight\\' id=\\'campaign_#{previous.id}\\'")
  end

  it "edit: should remove previously open [Edit Campaign] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    expect(rendered).to include(%/crm.flick('campaign_#{previous}', 'remove');/)
  end

  it "edit from campaigns index page: should turn off highlight, hide [Create Campaign], and replace current campaign with [Edit Campaign] form" do
    params[:cancel] = nil

    render
    expect(rendered).to include(%/crm.highlight_off('campaign_#{@campaign.id}');/)
    expect(rendered).to include("crm.hide_form('create_campaign')")
    expect(rendered).to include("$('#campaign_#{@campaign.id}').html")
  end

  it "edit from campaign landing page: should show [Edit Campaign] form" do
    params[:cancel] = "false"

    render
    expect(rendered).to include("$('#edit_campaign').html")
    expect(rendered).to include("crm.flip_form('edit_campaign')")
  end
end
