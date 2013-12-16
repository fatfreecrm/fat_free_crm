# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/promote" do
  before do
    login_and_assign
    assign(:users, [ current_user ])
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
    assign(:contact, FactoryGirl.create(:contact))
    assign(:opportunity, FactoryGirl.create(:opportunity))
    assign(:lead_status_total, Hash.new(1))
  end

  describe "no errors :" do
    before do
      assign(:lead, @lead = FactoryGirl.create(:lead, :status => "converted", :user => current_user, :assignee => current_user))
    end

    describe "from lead landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [Convert Lead] form" do
        render
        rendered.should_not include("lead_#{@lead.id}")
        rendered.should include("crm.flip_form('convert_lead'")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Lead Summary")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#summary').effect('shake'")
      end
    end

    describe "from lead index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Convert Lead] with lead partial and highlight it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        rendered.should include("$('#filters').effect('shake'")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Lead Status")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#filters').effect('shake'")
      end
    end

    describe "from related campaign page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
        assign(:campaign, FactoryGirl.create(:campaign))
        assign(:stage, Setting.unroll(:opportunity_stage))
        assign(:opportunity, @opportunity = FactoryGirl.create(:opportunity))
      end

      it "should replace [Convert Lead] with lead partial and highlight it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        rendered.should include(%Q/$('#lead_#{@lead.id}').effect("highlight"/)
      end

      it "should update campaign sidebar" do
        render

        rendered.should include("#sidebar")
        rendered.should have_text("Summary")
        rendered.should have_text("Recent Items")
      end

      it "should insert new opportunity if any" do
        render

        rendered.should include("$('#opportunities').prepend('<li class=\\'highlight opportunity\\' id=\\'opportunity_#{@opportunity.id}")
      end

    end
  end # no errors

  describe "validation errors:" do
    before do
      assign(:lead, @lead = FactoryGirl.create(:lead, :status => "new", :user => current_user, :assignee => current_user))
    end

    describe "from lead landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        rendered.should include("$('#convert_lead').html")
        rendered.should include(%Q/$('#convert_lead').effect("shake"/)
      end
    end

    describe "from lead index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').html")
        rendered.should include(%Q/$('#lead_#{@lead.id}').effect("shake"/)
      end
    end

    describe "from related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').html")
        rendered.should include(%Q/$('#lead_#{@lead.id}').effect("shake"/)
      end
    end

    it "should handle new or existing account and set up calendar field" do
      render
      rendered.should include("crm.create_or_select_account")
      rendered.should include('focus()')
    end
  end # errors
end
