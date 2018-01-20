# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/create" do
  before do
    controller.controller_path = 'leads'
    login
    assign(:campaigns, [build_stubbed(:campaign)])
  end

  describe "create success" do
    before do
      assign(:lead, @lead = build_stubbed(:lead))
      assign(:leads, [@lead].paginate)
      assign(:lead_status_total, Hash.new(1))
    end

    it "should hide [Create Lead] form and insert lead partial" do
      render

      expect(rendered).to include("$('#leads').prepend('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
      expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("highlight"/)
    end

    it "should update sidebar when called from leads index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      render

      expect(rendered).to include("#sidebar")
      expect(rendered).to have_text("Lead Statuses")
      expect(rendered).to include("Recent Items")
      expect(rendered).to include("$('#filters').effect('shake'")
    end

    it "should update pagination when called from leads index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      render

      expect(rendered).to include("#paginate")
    end

    it "should update related asset sidebar from related asset" do
      assign(:campaign, campaign = create(:campaign))
      controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
      render

      expect(rendered).to include("#sidebar")
      expect(rendered).to have_text("Campaign Summary")
      expect(rendered).to have_text("Recent Items")
    end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_lead div" do
      assign(:lead, build(:lead, first_name: nil)) # make it invalid
      assign(:users, [build_stubbed(:user)])

      render

      expect(rendered).to include("$('#create_lead').html")
      expect(rendered).to include(%/$('#create_lead').effect("shake"/)
    end
  end
end
