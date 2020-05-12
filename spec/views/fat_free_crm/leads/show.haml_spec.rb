# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/leads/show" do
    before do
      view.extend FatFreeCrm::JavascriptHelper
      view.extend FatFreeCrm::CommentsHelper
      view.extend FatFreeCrm::AddressesHelper
      view.extend FatFreeCrm::AddressesHelper
      login
      assign(:lead, @lead = build_stubbed(:lead, id: 42))
      assign(:users, [current_user])
      assign(:comment, Comment.new)
      assign(:timeline, [build_stubbed(:comment, commentable: @lead)])

      # controller#controller_name and controller#action_name are not set in view specs
      allow(view.controller).to receive(:action_name).and_return("show")
    end

    it "should render lead landing page" do
      render
      expect(view).to render_template(partial: "fat_free_crm/comments/_new")
      expect(view).to render_template(partial: "fat_free_crm/shared/_timeline")
      expect(view).to render_template(partial: "fat_free_crm/shared/_tasks")

      expect(rendered).to have_tag("div[id=edit_lead]")
    end
  end
end
