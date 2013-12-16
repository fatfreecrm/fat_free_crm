# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/destroy" do
  before do
    login_and_assign
    assign(:opportunity, @opportunity = FactoryGirl.create(:opportunity))
    assign(:stage, Setting.unroll(:opportunity_stage))
    assign(:opportunity_stage_total, Hash.new(1))
  end

  it "should blind up destroyed opportunity partial" do
    render
    rendered.should include("slideUp")
  end

  it "should update opportunities sidebar when called from opportunities index" do
    assign(:opportunities, [ @opportunity ].paginate)
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render

    rendered.should include("#sidebar")
    rendered.should have_text("Recent Items")
    rendered.should include("$('#filters').effect('shake'")
  end

  it "should update pagination when called from opportunities index" do
    assign(:opportunities, [ @opportunity ].paginate)
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render

    rendered.should include("#paginate")
  end

  it "should update related account sidebar when called from related account" do
    assign(:account, account = FactoryGirl.create(:account))
    controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/#{account.id}"
    render

    rendered.should include("#sidebar")
    rendered.should have_text("Account Summary")
    rendered.should have_text("Recent Items")
  end

  it "should update related campaign sidebar when called from related campaign" do
    assign(:campaign, campaign = FactoryGirl.create(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    rendered.should include("#sidebar")
    rendered.should have_text("Campaign Summary")
    rendered.should have_text("Recent Items")
  end

  it "should update recently viewed items when called from related contact" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
    render

    rendered.should include("#recently")
  end

end
