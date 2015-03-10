# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index" do
  before do
    login_and_assign(admin: true)
  end

  it "renders a list of users" do
    assign(:users, [ FactoryGirl.create(:user) ].paginate)

    render
    view.should render_template(partial: "_user")
    view.should render_template(partial: "shared/_paginate_simple")
  end
end

