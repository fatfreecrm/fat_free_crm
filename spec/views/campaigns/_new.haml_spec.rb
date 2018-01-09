# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/_new" do
  include CampaignsHelper

  before do
    login
    assign(:campaign, Campaign.new)
    assign(:users, [current_user])
  end

  it "should render [create campaign] form" do
    render
    expect(view).to render_template(partial: "campaigns/_top_section")
    expect(view).to render_template(partial: "campaigns/_objectives")
    expect(view).to render_template(partial: "_permissions")

    expect(rendered).to have_tag("form[class=new_campaign]")
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [:campaign]

    render
    expect(rendered).to have_tag("textarea[id=campaign_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    expect(rendered).not_to have_tag("textarea[id=campaign_background_info]")
  end
end
