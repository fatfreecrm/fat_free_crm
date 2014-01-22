# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/destroy" do
  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead))
    assign(:lead_status_total, Hash.new(1))
  end

  it "should blind up destroyed lead partial" do
    render
    rendered.should include("slideUp")
  end

  it "should update leads sidebar when called from leads index" do
    assign(:leads, [ @lead ].paginate)
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
    render

    rendered.should include("#sidebar")
    rendered.should have_text("Recent Items")
    rendered.should include("$('#filters').effect('shake'")
  end

  it "should update pagination when called from leads index" do
    assign(:leads, [ @lead ].paginate)
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
    render

    rendered.should include("#paginate")
  end

  it "should update related asset sidebar when called from related asset" do
    assign(:campaign, campaign = FactoryGirl.create(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    rendered.should include("#sidebar")
    rendered.should have_text("Campaign Summary")
    rendered.should have_text("Recent Items")
  end

end
