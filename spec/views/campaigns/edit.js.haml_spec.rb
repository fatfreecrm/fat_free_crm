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
    assign(:campaign, @campaign = FactoryGirl.create(:campaign, :user => current_user))
    assign(:users, [ current_user ])
  end

  it "cancel from campaign index page: should replace [Edit Campaign] form with campaign partial" do
    params[:cancel] = "true"

    render
    rendered.should include("$('#campaign_#{@campaign.id}').replaceWith('<li class=\\'campaign highlight\\' id=\\'campaign_#{@campaign.id}\\'")
  end

  it "cancel from campaign landing page: should hide [Edit Campaign] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('edit_campaign'")
  end

  it "edit: should hide previously open [Edit Campaign] for and replace it with campaign partial" do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.create(:campaign, :user => current_user))

    render
    rendered.should include("$('#campaign_#{previous.id}').replaceWith('<li class=\\'campaign highlight\\' id=\\'campaign_#{previous.id}\\'")
  end

  it "edit: should remove previously open [Edit Campaign] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include(%Q/crm.flick('campaign_#{previous}', 'remove');/)
  end

  it "edit from campaigns index page: should turn off highlight, hide [Create Campaign], and replace current campaign with [Edit Campaign] form" do
    params[:cancel] = nil

    render
    rendered.should include(%Q/crm.highlight_off('campaign_#{@campaign.id}');/)
    rendered.should include("crm.hide_form('create_campaign')")
    rendered.should include("$('#campaign_#{@campaign.id}').html")
  end

  it "edit from campaign landing page: should show [Edit Campaign] form" do
    params[:cancel] = "false"

    render
    rendered.should include("$('#edit_campaign').html")
    rendered.should include("crm.flip_form('edit_campaign')")
  end

  it "should call JavaScript to set up popup Calendar" do
    params[:cancel] = nil

    render
    rendered.should include('focus()')
  end

end
