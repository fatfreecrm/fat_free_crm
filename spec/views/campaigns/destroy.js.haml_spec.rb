# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/destroy" do
  before do
    login_and_assign
    assign(:campaign, @campaign = FactoryGirl.create(:campaign, :user => current_user))
    assign(:campaigns, [ @campaign ].paginate)
    assign(:campaign_status_total, Hash.new(1))
    render
  end

  it "should blind up destroyed campaign partial" do
    rendered.should include("slideUp")
  end

  it "should update Campaigns sidebar" do
    rendered.should include("#sidebar")
    rendered.should have_text("Recent Items")
    rendered.should include(%Q/$('#filters').effect('shake'/)
  end

  it "should update pagination" do
    rendered.should include("#paginate")
  end

end
