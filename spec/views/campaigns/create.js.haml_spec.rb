# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/create" do
  before do
    login_and_assign
  end

  describe "create success" do
    before do
      assign(:campaign, @campaign = FactoryGirl.create(:campaign))
      assign(:campaigns, [ @campaign ].paginate)
      assign(:campaign_status_total, Hash.new(1))
      render
    end

    it "should hide [Create Campaign] form and insert campaign partial" do
      rendered.should include("$('#campaigns').prepend('<li class=\\'campaign highlight\\' id=\\'campaign_#{@campaign.id}\\'")
      rendered.should include(%Q/$('#campaign_#{@campaign.id}').effect("highlight"/)
    end

    it "should update pagination" do
      rendered.should include("#paginate")
    end

    it "should update Campaigns sidebar filters" do
      rendered.should include("#sidebar")
      rendered.should have_text("Campaign Statuses")
      rendered.should have_text("Recent Items")
    end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_campaign div" do
      assign(:campaign, FactoryGirl.build(:campaign, :name => nil)) # make it invalid
      assign(:users, [ FactoryGirl.create(:user) ])

      render

      rendered.should include("$('#create_campaign').html")
      rendered.should include(%Q/$('#create_campaign').effect("shake"/)
    end
  end

end
