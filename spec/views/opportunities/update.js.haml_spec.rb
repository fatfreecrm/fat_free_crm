# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/update" do
  before do
    login

    assign(:opportunity, @opportunity = build_stubbed(:opportunity, user: current_user, assignee: build_stubbed(:user)))
    assign(:users, [current_user])
    assign(:account, @account = build_stubbed(:account))
    assign(:accounts, [@account])
    assign(:stage, Setting.unroll(:opportunity_stage))
    assign(:opportunity_stage_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on opportunity landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
      end

      it "should flip [edit_opportunity] form" do
        render
        expect(rendered).not_to include("opportunity_#{@opportunity.id}")
        expect(rendered).to include("crm.flip_form('edit_opportunity'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
      end
    end

    describe "on opportunities index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should replace [Edit Opportunity] with opportunity partial and highlight it" do
        render
        expect(rendered).to include("$('#opportunity_#{@opportunity.id}').replaceWith")
        expect(rendered).to include(%/$('#opportunity_#{@opportunity.id}').effect("highlight"/)
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("sidebar")
        expect(rendered).to have_text("Opportunity Stages")
        expect(rendered).to have_text("Recent Items")
      end
    end

    describe "on related asset page -" do
      it "should update account sidebar" do
        assign(:account, account = build_stubbed(:account))
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/#{account.id}"
        render

        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
      end

      it "should update campaign sidebar" do
        assign(:campaign, campaign = build_stubbed(:campaign))
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
        render

        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Recent Items")
      end

      it "should update recently viewed items for contact" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
        render

        expect(rendered).to include("#recently")
      end

      it "should replace [Edit Opportunity] with opportunity partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
        render

        expect(rendered).to include(%/$('#opportunity_#{@opportunity.id}').effect("highlight"/)
      end
    end
  end

  describe "validation errors:" do
    before do
      @opportunity.errors.add(:name)
    end

    describe "on opportunity landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
      end

      it "should redraw the [edit_opportunity] form" do
        render
        expect(rendered).to include("$('#edit_opportunity').html")
        expect(rendered).to include('crm.create_or_select_account(false)')
        expect(rendered).to include('focus()')
      end
    end

    describe "on opportunities index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should redraw the [edit_opportunity] form" do
        render
        expect(rendered).to include("$('#opportunity_#{@opportunity.id}').html")
        expect(rendered).to include('crm.create_or_select_account(false)')
        expect(rendered).to include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "should show disabled accounts dropdown when called from accounts landing page" do
        render
        expect(rendered).to include("crm.create_or_select_account(#{@referer =~ %r{/accounts/}})")
      end

      it "should redraw the [edit_opportunity] form" do
        render
        expect(rendered).to include("$('#opportunity_#{@opportunity.id}').html")
        expect(rendered).to include('focus()')
      end
    end
  end
end
