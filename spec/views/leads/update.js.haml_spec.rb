# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/update" do
  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead, :user => current_user, :assignee => FactoryGirl.create(:user)))
    assign(:users, [ current_user ])
    assign(:campaigns, [ FactoryGirl.create(:campaign) ])
    assign(:lead_status_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [edit_lead] form" do
        render
        rendered.should_not include("lead_#{@lead.id}x")
        rendered.should include("crm.flip_form('edit_lead'")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Lead Summary")
        rendered.should include("$('#summary').effect('shake'")
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Edit Lead] with lead partial and highlight it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        rendered.should include("$('#filters').effect('shake'")
      end

      it "should update sidebar" do
        render
        rendered.should include("#sidebar")
        rendered.should have_text("Lead Statuses")
        rendered.should have_text("Recent Items")
        rendered.should include("$('#filters').effect('shake'")
      end
    end

    describe "on related asset page -" do
      before do
        assign(:campaign, FactoryGirl.create(:campaign))
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should replace [Edit Lead] with lead partial and highlight it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        rendered.should include(%Q/$('#lead_#{@lead.id}').effect("highlight"/)
      end

      it "should update campaign sidebar" do
        assign(:campaign, campaign = FactoryGirl.create(:campaign))
        render

        rendered.should include("sidebar")
        rendered.should have_text("Campaign Summary")
        rendered.should have_text("Recent Items")
      end
    end

  end # no errors

  describe "validation errors :" do
    before do
      @lead.errors.add(:first_name)
    end

    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        rendered.should include("#edit_lead")
        rendered.should include(%Q/$('#edit_lead').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').html")
        rendered.should include(%Q/$('#lead_#{@lead.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        rendered.should include("$('#lead_#{@lead.id}').html")
        rendered.should include(%Q/$('#lead_#{@lead.id}').effect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
