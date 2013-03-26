# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_edit" do
  include OpportunitiesHelper

  before do
    login_and_assign
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render [edit opportunity] form" do
    assign(:users, [ current_user ])
    assign(:opportunity, @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign = FactoryGirl.create(:campaign)))
    render

    rendered.should have_tag("form[class=edit_opportunity]") do
      with_tag "input[type=hidden][id=opportunity_user_id][value=#{@opportunity.user_id}]"
      with_tag "input[type=hidden][id=opportunity_campaign_id][value=#{@opportunity.campaign_id}]"
    end
  end

  it "should pick default assignee (Myself)" do
    assign(:users, [ current_user ])
    assign(:opportunity, FactoryGirl.create(:opportunity, :assignee => nil))
    render

    rendered.should have_tag("select[id=opportunity_assigned_to]") do |options|
      options.to_s.should_not include(%Q/selected="selected"/)
    end
  end

  it "should show correct assignee" do
    @user = FactoryGirl.create(:user)
    assign(:users, [ current_user, @user ])
    assign(:opportunity, FactoryGirl.create(:opportunity, :assignee => @user))
    render

    rendered.should have_tag("select[id=opportunity_assigned_to]") do |options|
      with_tag "option[selected=selected]"
      with_tag "option[value=#{@user.id}]"
    end
  end

  it "should render background info field if settings require so" do
    assign(:users, [ current_user ])
    assign(:opportunity, FactoryGirl.create(:opportunity))
    Setting.background_info = [ :opportunity ]

    render
    rendered.should have_tag("textarea[id=opportunity_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    assign(:users, [ current_user ])
    assign(:opportunity, FactoryGirl.create(:opportunity))
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=opportunity_background_info]")
  end
end
