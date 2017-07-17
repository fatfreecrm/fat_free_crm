# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index" do
  include AccountsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Account.per_page
    assign :sort_by,  Account.sort_by
    assign :ransack_search, Account.ransack
    login_and_assign
  end

  it "should render account name" do
    assign(:accounts, [FactoryGirl.build_stubbed(:account, name: 'New Media Inc'), FactoryGirl.build_stubbed(:account)].paginate)
    render
    expect(rendered).to have_tag('a', text: "New Media Inc")
  end

  it "should render list of accounts if list of accounts is not empty" do
    assign(:accounts, [FactoryGirl.build_stubbed(:account), FactoryGirl.build_stubbed(:account)].paginate)

    render
    expect(view).to render_template(partial: "_account")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no accounts" do
    assign(:accounts, [].paginate)

    render
    expect(view).not_to render_template(partial: "_account")
    expect(view).to render_template(partial: "shared/_empty")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end
end
