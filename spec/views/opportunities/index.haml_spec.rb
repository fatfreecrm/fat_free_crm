# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index" do
  include OpportunitiesHelper

  before do
    login_and_assign
    view.lookup_context.prefixes << 'entities'
    assign :stage, Setting.unroll(:opportunity_stage)
    assign :per_page, Opportunity.per_page
    assign :sort_by,  Opportunity.sort_by
    assign :ransack_search, Opportunity.search
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assign(:opportunities, [FactoryGirl.build_stubbed(:opportunity)].paginate)

    render
    expect(view).to render_template(partial: "_opportunity")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no opportunities" do
    assign(:opportunities, [].paginate)

    render
    expect(view).not_to render_template(partial: "_opportunities")
    expect(view).to render_template(partial: "shared/_empty")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end
end
