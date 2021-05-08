# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/reject" do
  before do
    login
    assign(:lead, @lead = build_stubbed(:lead, status: "new"))
    assign(:lead_status_total, Hash.new(1))
  end

  it "should refresh current lead partial" do
    render

    expect(rendered).to include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
    expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("highlight"/)
  end

  it "should update sidebar filters when called from index page" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
    render

    expect(rendered).to include("$('#sidebar').html")
  end

  it "should update sidebar summary when called from landing page" do
    render

    expect(rendered).to include("$('#sidebar').html")
  end

  it "should update campaign sidebar if called from campaign landing page" do
    assign(:campaign, campaign = build_stubbed(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    expect(rendered).to include("#sidebar")
    expect(rendered).to have_text("Recent Items")
  end
end
