# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/home/index.html.haml" do
    before do
      view.extend ::FatFreeCrm::Engine.routes.url_helpers
      login
    end

    it "should render list of activities if it's not empty" do
      assign(:activities, [build_stubbed(:version, event: "update", item: build_stubbed(:account))])
      assign(:my_tasks, [])
      assign(:my_opportunities, [])
      assign(:my_accounts, [])
      render
      expect(view).to render_template(partial: "_activity")
    end

    it "should render a message if there're no activities" do
      assign(:activities, [])
      assign(:my_tasks, [])
      assign(:my_opportunities, [])
      assign(:my_accounts, [])
      render
      expect(view).not_to render_template(partial: "_activity")

      expect(rendered).to include("No activity records found.")
    end
  end
end