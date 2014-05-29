# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/index" do
  include CampaignsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Campaign.per_page
    assign :sort_by,  Campaign.sort_by
    assign :ransack_search, Campaign.search
    login
  end

  it "should render list of accounts if list of campaigns is not empty" do
    assign(:campaigns, [ FactoryGirl.create(:campaign) ].paginate)

    render
    view.should render_template(:partial => "_campaign")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no campaigns" do
    assign(:campaigns, [].paginate)

    render
    view.should_not render_template(:partial => "_campaigns")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

end
