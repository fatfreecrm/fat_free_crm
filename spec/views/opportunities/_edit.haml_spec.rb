# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_edit" do
  include OpportunitiesHelper

  before do
    login
    assign(:account, @account = build_stubbed(:account))
    assign(:accounts, [@account])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render [edit opportunity] form" do
    assign(:users, [current_user])
    assign(:opportunity, @opportunity = build_stubbed(:opportunity, campaign: @campaign = build_stubbed(:campaign)))
    render

    expect(rendered).to have_tag("form[class=edit_opportunity]") do
      with_tag "input[type=hidden][id=opportunity_user_id][value='#{@opportunity.user_id}']"
      with_tag "input[type=hidden][id=opportunity_campaign_id][value='#{@opportunity.campaign_id}']"
    end
  end

  it "should pick default assignee (Myself)" do
    assign(:users, [current_user])
    assign(:opportunity, build_stubbed(:opportunity, assignee: nil))
    render

    expect(rendered).to have_tag("select[id=opportunity_assigned_to]") do |options|
      expect(options.to_s).not_to include(%(selected="selected"))
    end
  end

  it "should show correct assignee" do
    @user = create(:user)
    assign(:users, [current_user, @user])
    assign(:opportunity, create(:opportunity, assignee: @user))
    render

    expect(rendered).to have_tag("select[id=opportunity_assigned_to]") do |_options|
      with_tag "option[selected=selected]"
      with_tag "option[value='#{@user.id}']"
    end
  end

  it "should render background info field if settings require so" do
    assign(:users, [current_user])
    assign(:opportunity, build_stubbed(:opportunity))
    Setting.background_info = [:opportunity]

    render
    expect(rendered).to have_tag("textarea[id=opportunity_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    assign(:users, [current_user])
    assign(:opportunity, build_stubbed(:opportunity))
    Setting.background_info = []

    render
    expect(rendered).not_to have_tag("textarea[id=opportunity_background_info]")
  end
end
