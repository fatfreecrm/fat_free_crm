# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/promote" do
  before do
    login
    assign(:users, [current_user])
    assign(:account, @account = build_stubbed(:account))
    assign(:accounts, [@account])
    assign(:contact, build_stubbed(:contact))
    assign(:opportunity, build_stubbed(:opportunity))
    assign(:lead_status_total, Hash.new(1))
  end

  describe "no errors :" do
    before do
      assign(:lead, @lead = build_stubbed(:lead, status: "converted", user: current_user, assignee: current_user))
    end

    describe "from lead landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [Convert Lead] form" do
        render
        expect(rendered).not_to include("lead_#{@lead.id}")
        expect(rendered).to include("crm.flip_form('convert_lead'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Lead Summary")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to include("$('#summary').effect('shake'")
      end
    end

    describe "from lead index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Convert Lead] with lead partial and highlight it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        expect(rendered).to include("$('#filters').effect('shake'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Lead Status")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to include("$('#filters').effect('shake'")
      end
    end

    describe "from related campaign page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
        assign(:campaign, build_stubbed(:campaign))
        assign(:stage, Setting.unroll(:opportunity_stage))
        assign(:opportunity, @opportunity = build_stubbed(:opportunity))
      end

      it "should replace [Convert Lead] with lead partial and highlight it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("highlight"/)
      end

      it "should update campaign sidebar" do
        render

        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Summary")
        expect(rendered).to have_text("Recent Items")
      end

      it "should insert new opportunity if any" do
        render

        expect(rendered).to include("$('#opportunities').prepend('<li class=\\'highlight opportunity\\' id=\\'opportunity_#{@opportunity.id}")
      end
    end
  end

  describe "validation errors:" do
    before do
      assign(:lead, @lead = build_stubbed(:lead, status: "new", user: current_user, assignee: current_user))
    end

    describe "from lead landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        expect(rendered).to include("$('#convert_lead').html")
        expect(rendered).to include(%/$('#convert_lead').effect("shake"/)
      end
    end

    describe "from lead index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').html")
        expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("shake"/)
      end
    end

    describe "from related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').html")
        expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("shake"/)
      end
    end

    it "should handle new or existing account and set up calendar field" do
      render
      expect(rendered).to include("crm.create_or_select_account")
      expect(rendered).to include('focus()')
    end
  end
end
