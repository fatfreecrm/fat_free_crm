# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/new" do
  include CampaignsHelper

  before do
    login_and_assign
    assign(:campaign, Campaign.new(:user => current_user))
    assign(:users, [ current_user ])
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include("crm.flick('empty', 'toggle')")
  end

  describe "new campaign" do
    it "should render [new] template into :create_campaign div" do
      params[:cancel] = nil
      render

      rendered.should include("$('#create_campaign').html")
    end

    it "should call JavaScript functions to load Calendar popup" do
      params[:cancel] = nil
      render

      rendered.should include("crm.flip_form('create_campaign')")
    end
  end

  describe "cancel new campaign" do
    it "should hide [create campaign] form" do
      params[:cancel] = "true"
      render

      rendered.should_not include("#create_campaignx")
      rendered.should include("crm.flip_form('create_campaign')")
    end
  end

end
