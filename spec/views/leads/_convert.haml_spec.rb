# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_convert" do
  include LeadsHelper

  before do
    login
    @account = build_stubbed(:account)
    assign(:lead, build_stubbed(:lead))
    assign(:users, [current_user])
    assign(:account, @account)
    assign(:accounts, [@account])
    assign(:opportunity, build_stubbed(:opportunity))
  end

  it "should render [convert lead] form" do
    render
    expect(view).to render_template(partial: "leads/_opportunity")
    expect(view).to render_template(partial: "leads/_convert_permissions")

    expect(rendered).to have_tag("form[class=edit_lead]")
  end
end
