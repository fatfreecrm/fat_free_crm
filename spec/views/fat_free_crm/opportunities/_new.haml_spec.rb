# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/opportunities/_new" do

    before do
      view.extend FatFreeCrm::AccountsHelper
      login
      assign(:opportunity, build(:opportunity))
      @account = build_stubbed(:account)
      assign(:account, @account)
      assign(:accounts, [@account])
      assign(:users, [current_user])
      assign(:stage, Setting.unroll(:opportunity_stage))
    end

    it "should render [create opportunity] form" do
      render
      expect(view).to render_template(partial: "fat_free_crm/opportunities/_top_section")
      expect(view).to render_template(partial: "fat_free_crm/entities/_permissions")

      expect(rendered).to have_tag("form[class=new_opportunity]")
    end

    it "should pick default assignee (Myself)" do
      render
      expect(rendered).to have_tag("select[id=opportunity_assigned_to]") do |options|
        expect(options.to_s).not_to include(%(selected="selected"))
      end
    end

    it "should render background info field if settings require so" do
      Setting.background_info = [:opportunity]

      render
      expect(rendered).to have_tag("textarea[id=opportunity_background_info]")
    end

    it "should not render background info field if settings do not require so" do
      Setting.background_info = []

      render
      expect(rendered).not_to have_tag("textarea[id=opportunity_background_info]")
    end
  end
end