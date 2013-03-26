# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/_new" do
  before do
    login_and_assign(:admin => true)
    assign(:user, User.new)
    assign(:users, [ current_user ])
  end

  it "renders [Create User] form" do
    render
    view.should render_template(:partial => "admin/users/_profile")

    rendered.should have_tag("form[class=new_user]")
  end
end
