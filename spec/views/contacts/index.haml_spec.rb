# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/index" do
  include ContactsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Contact.per_page
    assign :sort_by,  Contact.sort_by
    assign :ransack_search, Contact.search
    login_and_assign
  end

  it "should render a list of contacts if it's not empty" do
    assign(:contacts, [FactoryGirl.build_stubbed(:contact)].paginate)

    render
    expect(view).to render_template(partial: "_contact")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no contacts" do
    assign(:contacts, [].paginate)

    render
    expect(view).not_to render_template(partial: "_contact")
    expect(view).to render_template(partial: "shared/_empty")
    expect(view).to render_template(partial: "shared/_paginate_with_per_page")
  end
end
