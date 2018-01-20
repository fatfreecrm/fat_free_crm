# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/reactivate" do
  before do
    login_admin
    assign(:user, @user = build_stubbed(:user, suspended_at: Time.now.yesterday))
  end

  it "reloads the requested user partial" do
    render

    expect(rendered).to include("user_#{@user.id}")
    expect(rendered).to include(%/$('#user_#{@user.id}').effect("highlight"/)
  end
end
