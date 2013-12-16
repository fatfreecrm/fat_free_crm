# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/update" do
  before do
    login_and_assign

    assign(:opportunity, @opportunity = FactoryGirl.create(:opportunity, :user => current_user, :assignee => FactoryGirl.create(:user)))
    assign(:users, [ current_user ])
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
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
        rendered.should_not include("opportunity_#{@opportunity.id}")
        rendered.should include("crm.flip_form('edit_opportunity'")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Opportunity At a Glance")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#summary').effect('shake'")
      end
    end

    describe "on opportunities index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should replace [Edit Opportunity] with opportunity partial and highlight it" do
        render
        rendered.should include("$('#opportunity_#{@opportunity.id}').replaceWith")
        rendered.should include(%Q/$('#opportunity_#{@opportunity.id}').effect("highlight"/)
      end

      it "should update sidebar" do
        render
        rendered.should include("sidebar")
        rendered.should have_text("Opportunity Stages")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#filters').effect('shake'")
      end
    end

    describe "on related asset page -" do
      it "should update account sidebar" do
        assign(:account, account = FactoryGirl.create(:account))
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/#{account.id}"
        render

        rendered.should include("#sidebar")
        rendered.should have_text("Account Summary")
        rendered.should have_text("Recent Items")
      end

      it "should update campaign sidebar" do
        assign(:campaign, campaign = FactoryGirl.create(:campaign))
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
        render

        rendered.should include("#sidebar")
        rendered.should have_text("Campaign Summary")
        rendered.should have_text("Recent Items")
      end

      it "should update recently viewed items for contact" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
        render

        rendered.should include("#recently")
      end

      it "should replace [Edit Opportunity] with opportunity partial and highlight it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
        render

        rendered.should include(%Q/$('#opportunity_#{@opportunity.id}').effect("highlight"/)
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

      it "should redraw the [edit_opportunity] form and shake it" do
        render
        rendered.should include("$('#edit_opportunity').html")
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include(%Q/$('#edit_opportunity').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on opportunities index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render
        rendered.should include("$('#opportunity_#{@opportunity.id}').html")
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include(%Q/$('#opportunity_#{@opportunity.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "should show disabled accounts dropdown when called from accounts landing page" do
        render
        rendered.should include("crm.create_or_select_account(#{@referer =~ /\/accounts\//})")
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render
        rendered.should include("$('#opportunity_#{@opportunity.id}').html")
        rendered.should include(%Q/$('#opportunity_#{@opportunity.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
