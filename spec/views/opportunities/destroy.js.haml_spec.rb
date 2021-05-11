# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/destroy" do
  before do
    login
    assign(:opportunity, @opportunity = build_stubbed(:opportunity))
    assign(:stage, Setting.unroll(:opportunity_stage))
    assign(:opportunity_stage_total, Hash.new(1))
  end

  it "should blind up destroyed opportunity partial" do
    render
    expect(rendered).to include("slideUp")
  end

  it "should update opportunities sidebar when called from opportunities index" do
    assign(:opportunities, [@opportunity].paginate)
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render

    expect(rendered).to include("#sidebar")
    expect(rendered).to have_text("Recent Items")
  end

  it "should update pagination when called from opportunities index" do
    assign(:opportunities, [@opportunity].paginate)
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render

    expect(rendered).to include("#paginate")
  end

  it "should update related account sidebar when called from related account" do
    assign(:account, account = build_stubbed(:account))
    controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/#{account.id}"
    render

    expect(rendered).to include("#sidebar")
    expect(rendered).to have_text("Recent Items")
  end

  it "should update related campaign sidebar when called from related campaign" do
    assign(:campaign, campaign = build_stubbed(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    expect(rendered).to include("#sidebar")
    expect(rendered).to have_text("Recent Items")
  end

  it "should update recently viewed items when called from related contact" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
    render

    expect(rendered).to include("#recently")
  end
end
