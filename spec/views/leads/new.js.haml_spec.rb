# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/new" do
  include LeadsHelper

  before do
    login_and_assign
    @campaign = FactoryGirl.create(:campaign)
    assign(:lead, Lead.new(:user => current_user))
    assign(:users, [ current_user ])
    assign(:campaign, @campaign)
    assign(:campaigns, [ @campaign ])
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include("crm.flick('empty', 'toggle')")
  end

  describe "new lead" do
    it "should render [new] template into :create_lead div" do
      params[:cancel] = nil
      render

      rendered.should include("$('#create_lead').html")
      rendered.should include("crm.flip_form('create_lead')")
    end
  end

  describe "cancel new lead" do
    it "should hide [create_lead] form" do
      params[:cancel] = "true"
      render

      rendered.should_not include("#create_lead")
      rendered.should include("crm.flip_form('create_lead');")
    end
  end

end
