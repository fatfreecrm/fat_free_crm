# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/users/_new" do
  before do
    login_admin
    assign(:user, User.new)
    assign(:users, [current_user])
  end

  it "renders [Create User] form" do
    render
    expect(view).to render_template(partial: "admin/users/_profile")

    expect(rendered).to have_tag("form[class=new_user]")
  end
end
