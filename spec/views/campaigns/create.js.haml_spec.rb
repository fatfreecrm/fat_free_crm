# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/create" do
  before do
    login
  end

  describe "create success" do
    before do
      assign(:campaign, @campaign = build_stubbed(:campaign))
      assign(:campaigns, [@campaign].paginate)
      assign(:campaign_status_total, Hash.new(1))
      render
    end

    it "should hide [Create Campaign] form and insert campaign partial" do
      expect(rendered).to include("$('#campaigns').prepend('<li class=\\'highlight campaign\\' id=\\'campaign_#{@campaign.id}\\'")
      expect(rendered).to include(%/$('#campaign_#{@campaign.id}').effect("highlight"/)
    end

    it "should update pagination" do
      expect(rendered).to include("#paginate")
    end

    it "should update Campaigns sidebar filters" do
      expect(rendered).to include("#sidebar")
      expect(rendered).to have_text("Campaign Statuses")
      expect(rendered).to have_text("Recent Items")
    end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_campaign div" do
      assign(:campaign, build(:campaign, name: nil)) # make it invalid
      assign(:users, [build_stubbed(:user)])

      render

      expect(rendered).to include("$('#create_campaign').html")
    end
  end
end
