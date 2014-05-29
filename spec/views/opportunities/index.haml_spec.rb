# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/index" do
  include OpportunitiesHelper

  before do
    login
    view.lookup_context.prefixes << 'entities'
    assign :stage, Setting.unroll(:opportunity_stage)
    assign :per_page, Opportunity.per_page
    assign :sort_by,  Opportunity.sort_by
    assign :ransack_search, Opportunity.search
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assign(:opportunities, [ FactoryGirl.create(:opportunity) ].paginate)

    render
    view.should render_template(:partial => "_opportunity")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no opportunities" do
    assign(:opportunities, [].paginate)

    render
    view.should_not render_template(:partial => "_opportunities")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

end
