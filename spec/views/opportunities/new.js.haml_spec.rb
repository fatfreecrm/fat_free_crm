# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "opportunities/new" do
  include OpportunitiesHelper

  before do
    login
    @account = build_stubbed(:account)
    assign(:opportunity, Opportunity.new(user: current_user))
    assign(:users, [current_user])
    assign(:account, @account)
    assign(:accounts, [@account])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should toggle empty message div if it exists" do
    render

    expect(rendered).to include("crm.flick('empty', 'toggle')")
  end

  describe "new opportunity" do
    it "should render [new] template into :create_opportunity div" do
      params[:cancel] = nil
      render

      expect(rendered).to include("#create_opportunity")
    end

    it "should call JavaScript functions to load Calendar popup" do
      params[:cancel] = nil
      render

      expect(rendered).to include("crm.flip_form('create_opportunity')")
    end
  end

  describe "cancel new opportunity" do
    it "should hide [create campaign] form" do
      params[:cancel] = "true"
      render

      expect(rendered).not_to include("#create_opportunity")
      expect(rendered).to include("crm.flip_form('create_opportunity')")
    end
  end
end
