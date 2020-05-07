# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

module FatFreeCrm
  describe "/fat_free_crm/home/index" do

    before do
      view.extend ::FatFreeCrm::Engine.routes.url_helpers
      view.extend FatFreeCrm::ApplicationHelper
      login
    end

    it "should render [activity] template with @activities collection" do
      assign(:activities, [build_stubbed(:version, id: 42, event: "update", item: build_stubbed(:account), whodunnit: current_user.id.to_s)])

      render template: 'fat_free_crm/home/index', formats: [:js]

      expect(rendered).to include("$('#activities').html")
      expect(rendered).to include("li class=\\'fat_free_crm_version\\' id=\\'fat_free_crm_version_42\\'")
    end

    it "should render a message if there're no activities" do
      assign(:activities, [])

      render template: 'fat_free_crm/home/index', formats: [:js]

      expect(rendered).to include("No activity records found.")
    end
  end
end