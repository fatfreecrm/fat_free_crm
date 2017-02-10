# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/update" do
  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.build_stubbed(:lead, user: current_user, assignee: FactoryGirl.build_stubbed(:user)))
    assign(:users, [current_user])
    assign(:campaigns, [FactoryGirl.build_stubbed(:campaign)])
    assign(:lead_status_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [edit_lead] form" do
        render
        expect(rendered).not_to include("lead_#{@lead.id}x")
        expect(rendered).to include("crm.flip_form('edit_lead'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Lead Summary")
        expect(rendered).to include("$('#summary').effect('shake'")
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Edit Lead] with lead partial and highlight it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        expect(rendered).to include("$('#filters').effect('shake'")
      end

      it "should update sidebar" do
        render
        expect(rendered).to include("#sidebar")
        expect(rendered).to have_text("Lead Statuses")
        expect(rendered).to have_text("Recent Items")
        expect(rendered).to include("$('#filters').effect('shake'")
      end
    end

    describe "on related asset page -" do
      before do
        assign(:campaign, FactoryGirl.build_stubbed(:campaign))
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should replace [Edit Lead] with lead partial and highlight it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').replaceWith('<li class=\\'highlight lead\\' id=\\'lead_#{@lead.id}\\'")
        expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("highlight"/)
      end

      it "should update campaign sidebar" do
        assign(:campaign, FactoryGirl.build_stubbed(:campaign))
        render

        expect(rendered).to include("sidebar")
        expect(rendered).to have_text("Campaign Summary")
        expect(rendered).to have_text("Recent Items")
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
        expect(rendered).to include("#edit_lead")
        expect(rendered).to include(%/$('#edit_lead').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').html")
        expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        expect(rendered).to include("$('#lead_#{@lead.id}').html")
        expect(rendered).to include(%/$('#lead_#{@lead.id}').effect("shake"/)
        expect(rendered).to include('focus()')
      end
    end
  end # errors
end
