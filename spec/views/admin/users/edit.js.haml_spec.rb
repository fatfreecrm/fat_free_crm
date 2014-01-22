# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/edit" do
  before do
    login_and_assign(:admin => true)
    assign(:user, @user = FactoryGirl.create(:user))
  end

  it "cancel replaces [Edit User] form with user partial" do
    params[:cancel] = "true"
    render

    rendered.should include("$('#user_#{@user.id}').replaceWith")
  end

  it "edit hides previously open [Edit User] and replaces it with user partial" do
    assign(:previous, previous = FactoryGirl.create(:user))
    render

    rendered.should include("user_#{previous.id}")
  end

  it "edit removes previously open [Edit User] if it's no longer available" do
    assign(:previous, previous = 41)
    render

    rendered.should include(%Q/crm.flick('user_#{previous}', 'remove');/)
  end

  it "edit turns off highlight, hides [Create User] form, and replaces current user with [Edit User] form" do
    render

    rendered.should include(%Q/crm.highlight_off('user_#{@user.id}');/)
    rendered.should include(%Q/crm.hide_form('create_user')/)
    rendered.should include("user_#{@user.id}")
  end

end

