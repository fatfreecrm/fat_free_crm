# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/update" do
  before do
    login_and_assign
    assign(:campaign, @campaign = FactoryGirl.create(:campaign, :user => current_user))
    assign(:users, [ current_user ])
    assign(:status, Setting.campaign_status)
    assign(:campaign_status_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should flip [edit_campaign] form" do
        render
        rendered.should_not include("campaign_#{@campaign.id}")
        rendered.should include("crm.flip_form('edit_campaign'")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Campaign Summary")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#summary').effect('shake'")
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      end

      it "should replace [Edit Campaign] with campaign partial and highlight it" do
        render
        rendered.should include("$('#campaign_#{@campaign.id}').replaceWith('<li class=\\'campaign highlight\\' id=\\'campaign_#{@campaign.id}\\'")
        rendered.should include(%Q/$('#campaign_#{@campaign.id}').effect("highlight"/)
      end
    end
  end # no errors

  describe "validation errors:" do
    describe "on landing page -" do
      before do
        @campaign.errors.add(:name)
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_campaign] form and shake it" do
        render
        rendered.should include("$('#edit_campaign').html")
        rendered.should include(%Q/$('#edit_campaign').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on index page -" do
      before do
        @campaign.errors.add(:name)
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      end

      it "should redraw the [edit_campaign] form and shake it" do
        render
        rendered.should include("$('#campaign_#{@campaign.id}').html")
        rendered.should include(%Q/$('#campaign_#{@campaign.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
