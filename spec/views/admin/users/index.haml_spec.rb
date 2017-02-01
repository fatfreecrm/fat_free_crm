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
    assign(:users, [FactoryGirl.build_stubbed(:user)].paginate)

    render
    expect(view).to render_template(partial: "_user")
    expect(view).to render_template(partial: "shared/_paginate")
  end
end
