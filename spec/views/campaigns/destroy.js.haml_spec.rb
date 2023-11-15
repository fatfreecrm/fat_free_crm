# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "campaigns/destroy" do
  before do
    login
    assign(:campaign, @campaign = build_stubbed(:campaign, user: current_user))
    assign(:campaigns, [@campaign].paginate)
    assign(:campaign_status_total, Hash.new(1))
    render
  end

  it "should blind up destroyed campaign partial" do
    expect(rendered).to include("slideUp")
  end

  it "should update Campaigns sidebar" do
    expect(rendered).to include("#sidebar")
    expect(rendered).to have_text("Recent Items")
  end

  it "should update pagination" do
    expect(rendered).to include("#paginate")
  end
end
