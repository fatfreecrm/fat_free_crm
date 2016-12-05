# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/show" do
  include CampaignsHelper

  before do
    login_and_assign
    @campaign = FactoryGirl.create(:campaign, id: 42,
                                              leads: [FactoryGirl.create(:lead)],
                                              opportunities: [FactoryGirl.create(:opportunity)])
    assign(:campaign, @campaign)
    assign(:users, [current_user])
    assign(:comment, Comment.new)
    assign(:timeline, [FactoryGirl.create(:comment, commentable: @campaign)])
    allow(view).to receive(:params) { { id: 123 } }
  end

  it "should render campaign landing page" do
    render
    expect(view).to render_template(partial: "comments/_new")
    expect(view).to render_template(partial: "shared/_timeline")
    expect(view).to render_template(partial: "shared/_tasks")
    expect(view).to render_template(partial: "leads/_leads")
    expect(view).to render_template(partial: "opportunities/_opportunities")

    expect(rendered).to have_tag("div[id=edit_campaign]")
  end
end
