# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "campaigns/update" do
  before do
    login
    assign(:campaign, @campaign = build_stubbed(:campaign, user: current_user))
    assign(:users, [current_user])
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
        expect(rendered).not_to include("campaign_#{@campaign.id}")
        expect(rendered).to include("crm.flip_form('edit_campaign'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      end

      it "should replace [Edit Campaign] with campaign partial and highlight it" do
        render
        expect(rendered).to include("$('#campaign_#{@campaign.id}').replaceWith('<li class=\\'highlight campaign\\' id=\\'campaign_#{@campaign.id}\\'")
        expect(rendered).to include(%/$('#campaign_#{@campaign.id}').effect("highlight"/)
      end
    end
  end

  describe "validation errors:" do
    describe "on landing page -" do
      before do
        @campaign.errors.add(:name)
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_campaign] form" do
        render
        expect(rendered).to include("$('#edit_campaign').html")
        expect(rendered).to include('focus()')
      end
    end

    describe "on index page -" do
      before do
        @campaign.errors.add(:name)
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      end

      it "should redraw the [edit_campaign] form" do
        render
        expect(rendered).to include("$('#campaign_#{@campaign.id}').html")
        expect(rendered).to include('focus()')
      end
    end
  end
end
