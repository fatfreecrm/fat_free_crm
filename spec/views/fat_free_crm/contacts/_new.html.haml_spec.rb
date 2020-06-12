# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/contacts/_new" do

    before do
      login
      @account = build_stubbed(:account)
      assign(:contact, Contact.new)
      assign(:users, [current_user])
      assign(:account, @account)
      assign(:accounts, [@account])
    end

    it "should render [create contact] form" do
      render
      expect(view).to render_template(partial: "fat_free_crm/contacts/_top_section")
      expect(view).to render_template(partial: "fat_free_crm/contacts/_extra")
      # Edit Custom Field Group only there if custom field group is present
      # expect(view).to render_template(partial: "fat_free_crm/fields/edit_custom_field_group")
      expect(rendered).to include("<details class='idc-panel contact-identifiers'>")
      expect(rendered).to include("<details class='idc-panel contact-assignments'>")
      expect(rendered).to include("<details class='idc-panel contact-absences'>")
      expect(rendered).to include("<summary>Comment</summary>")
      expect(view).to render_template(partial: "fat_free_crm/contacts/_web")
      expect(rendered).to include('<label for="contact_group_ids">Groups:</label>')
      expect(view).to render_template(partial: "fat_free_crm/entities/_permissions")


      expect(rendered).to have_tag("form[class=new_contact]")
    end

    it "should pick default assignee (Myself)" do
      render
      expect(rendered).to have_tag("select[id=contact_assigned_to]") do |options|
        expect(options.to_s).not_to include(%(selected="selected"))
      end
    end

    it "should render background info field if settings require so" do
      Setting.background_info = [:contact]

      render
      expect(rendered).to have_tag("textarea[id=contact_background_info]")
    end

    it "should not render background info field if settings do not require so" do
      Setting.background_info = []

      render
      expect(rendered).not_to have_tag("textarea[id=contact_background_info]")
    end
  end
end
