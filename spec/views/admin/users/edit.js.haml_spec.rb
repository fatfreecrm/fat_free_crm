# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/edit" do
  before do
    login_admin
    assign(:user, @user = build_stubbed(:user))
  end

  it "cancel replaces [Edit User] form with user partial" do
    params[:cancel] = "true"
    render

    expect(rendered).to include("$('#user_#{@user.id}').replaceWith")
  end

  it "edit hides previously open [Edit User] and replaces it with user partial" do
    assign(:previous, previous = build_stubbed(:user))
    render

    expect(rendered).to include("user_#{previous.id}")
  end

  it "edit removes previously open [Edit User] if it's no longer available" do
    assign(:previous, previous = 41)
    render

    expect(rendered).to include(%/crm.flick('user_#{previous}', 'remove');/)
  end

  it "edit turns off highlight, hides [Create User] form, and replaces current user with [Edit User] form" do
    render

    expect(rendered).to include(%/crm.highlight_off('user_#{@user.id}');/)
    expect(rendered).to include(%/crm.hide_form('create_user')/)
    expect(rendered).to include("user_#{@user.id}")
  end
end
