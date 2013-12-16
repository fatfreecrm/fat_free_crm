# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/create" do
  before do
    controller.controller_path = 'leads'
    login_and_assign
    assign(:campaigns, [ FactoryGirl.create(:campaign) ])
  end

  describe "create success" do
    before do
      assign(:lead, @lead = FactoryGirl.create(:lead))
      assign(:leads, [ @lead ].paginate)
      assign(:lead_status_total, Hash.new(1))
    end

    it "should hide [Create Lead] form and insert lead partial" do
      render

      rendered.should include("$('#leads').prepend('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
      rendered.should include(%Q/$('#lead_#{@lead.id}').effect("highlight"/)
    end

    it "should update sidebar when called from leads index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      render

      rendered.should include("#sidebar")
      rendered.should have_text("Lead Statuses")
      rendered.should include("Recent Items")
      rendered.should include("$('#filters').effect('shake'")
    end

    it "should update pagination when called from leads index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      render

      rendered.should include("#paginate")
    end

    it "should update related asset sidebar from related asset" do
      assign(:campaign, campaign = FactoryGirl.create(:campaign))
      controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
      render

      rendered.should include("#sidebar")
      rendered.should have_text("Campaign Summary")
      rendered.should have_text("Recent Items")
    end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_lead div" do
      assign(:lead, FactoryGirl.build(:lead, :first_name => nil)) # make it invalid
      assign(:users, [ FactoryGirl.create(:user) ])

      render

      rendered.should include("$('#create_lead').html")
      rendered.should include(%Q/$('#create_lead').effect("shake"/)
    end
  end
end

