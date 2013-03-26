# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/reject" do
  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead, :status => "new"))
    assign(:lead_status_total, Hash.new(1))
  end

  it "should refresh current lead partial" do
    render

    rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("li[id=lead_#{@lead.id}]")
    end
    rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
  end

  it "should update sidebar filters when called from index page" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
    render

    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
    end
    rendered.should include('$("filters").visualEffect("shake"')
  end

  it "should update sidebar summary when called from landing page" do
    render

    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=summary]")
    end
    rendered.should include('$("summary").visualEffect("shake"')
  end

  it "should update campaign sidebar if called from campaign landing page" do
    assign(:campaign, campaign = FactoryGirl.create(:campaign))
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render

    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[class=panel][id=summary]")
      with_tag("div[class=panel][id=recently]")
    end
  end

end
