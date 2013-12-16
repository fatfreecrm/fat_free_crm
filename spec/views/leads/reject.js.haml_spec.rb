# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/reject" do
  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead, :status => "new"))
    assign(:lead_status_total, Hash.new(1))
  end

  it "should refresh current lead partial" do
    render

    rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
    rendered.should include(%Q/$('#lead_#{@lead.id}').effect("highlight"/)
  end

  it "should update sidebar filters when called from index page" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
    render

    rendered.should include("$('#sidebar').html")
    rendered.should include("$('#filters').effect('shake'")
  end

  it "should update sidebar summary when called from landing page" do
    render

    rendered.should include("$('#sidebar').html")
    rendered.should include("$('#summary').effect('shake'")
  end

  it "should update campaign sidebar if called from campaign landing page" do
    assign(:campaign, campaign = FactoryGirl.create(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    rendered.should include("#sidebar")
    rendered.should have_text("Summary")
    rendered.should have_text("Recent Items")
  end

end
