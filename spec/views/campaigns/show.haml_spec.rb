# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/show" do
  include CampaignsHelper

  before do
    login
    @campaign = FactoryGirl.create(:campaign, :id => 42,
      :leads => [ FactoryGirl.create(:lead) ],
      :opportunities => [ FactoryGirl.create(:opportunity) ])
    assign(:campaign, @campaign)
    assign(:users, [ current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ FactoryGirl.create(:comment, :commentable => @campaign) ])
    view.stub(:params) { {:id => 123} }
  end

  it "should render campaign landing page" do
    render
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")
    view.should render_template(:partial => "leads/_leads")
    view.should render_template(:partial => "opportunities/_opportunities")

    rendered.should have_tag("div[id=edit_campaign]")
  end

end
