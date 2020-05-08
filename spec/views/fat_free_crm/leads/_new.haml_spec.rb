# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module FatFreeCrm
  describe "fat_free_crm/leads/_new" do

    before do
      view.extend FatFreeCrm::UsersHelper
      view.extend FatFreeCrm::AddressesHelper
      login
      assign(:lead, build(:lead))
      assign(:users, [current_user])
      assign(:campaign, @campaign = build_stubbed(:campaign))
      assign(:campaigns, [@campaign])
    end

    it "should render [create lead] form" do
      render
      expect(view).to render_template(partial: "fat_free_crm/leads/_top_section")
      expect(view).to render_template(partial: "fat_free_crm/leads/_status")
      expect(view).to render_template(partial: "fat_free_crm/leads/_contact")
      expect(view).to render_template(partial: "fat_free_crm/leads/_web")
      expect(view).to render_template(partial: "fat_free_crm/entities/_permissions")

      expect(rendered).to have_tag("form[class=new_lead]")
    end

    it "should render background info field if settings require so" do
      Setting.background_info = [:lead]

      render
      expect(rendered).to have_tag("textarea[id=lead_background_info]")
    end

    it "should not render background info field if settings do not require so" do
      Setting.background_info = []

      render
      expect(rendered).not_to have_tag("textarea[id=lead_background_info]")
    end
  end
end
