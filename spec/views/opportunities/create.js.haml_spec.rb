# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/create" do
  before do
    login
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  describe "create success" do
    before do
      assign(:opportunity, @opportunity = build_stubbed(:opportunity))
      assign(:opportunities, [@opportunities].paginate)
      assign(:opportunity_stage_total, Hash.new(1))
    end

    it "should hide [Create Opportunity] form and insert opportunity partial" do
      render

      expect(rendered).to include("$('#opportunities').prepend('<li class=\\'highlight opportunity\\' id=\\'opportunity_#{@opportunity.id}\\'")
      expect(rendered).to include(%/$('#opportunity_#{@opportunity.id}').effect("highlight"/)
    end

    it "should update sidebar filters and recently viewed items when called from opportunities page" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      render

      expect(rendered).to include("#sidebar")
      expect(rendered).to have_text("Opportunity Stages")
      expect(rendered).to have_text("Recent Items")
    end

    it "should update pagination when called from opportunities index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      render

      expect(rendered).to include("#paginate")
    end

    it "should update related account sidebar when called from related account" do
      assign(:account, account = create(:account))
      controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/#{account.id}"
      render

      expect(rendered).to include("#sidebar")
      expect(rendered).to have_text("Recent Items")
    end

    it "should update related campaign sidebar when called from related campaign" do
      assign(:campaign, campaign = create(:campaign))
      controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
      render

      expect(rendered).to include("#sidebar")
      expect(rendered).to have_text("Recent Items")
    end

    it "should update sidebar when called from related contact" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
      render

      expect(rendered).to include("#recently")
    end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_opportunity div" do
      assign(:opportunity, build(:opportunity, name: nil)) # make it invalid
      @account = build_stubbed(:account)
      assign(:users, [build_stubbed(:user)])
      assign(:account, @account)
      assign(:accounts, [@account])

      render

      expect(rendered).to include("$('#create_opportunity').html")
      expect(rendered).to include("crm.create_or_select_account(false)")
    end
  end
end
