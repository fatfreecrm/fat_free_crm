# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index" do
  include LeadsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Lead.per_page
    assign :sort_by,  Lead.sort_by
    assign :ransack_search, Lead.ransack
    login_and_assign
  end

  it "should render list of accounts if list of leads is not empty" do
    assign(:leads, [FactoryGirl.build_stubbed(:lead)].paginate(page: 1, per_page: 20))

    render
    expect(view).to render_template(partial: "_lead")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no leads" do
    assign(:leads, [].paginate(page: 1, per_page: 20))

    render
    expect(view).not_to render_template(partial: "_leads")
    expect(view).to render_template(partial: "shared/_empty")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end
end
