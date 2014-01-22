# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/password" do
  include UsersHelper

  before do
    login_and_assign
    assign(:user, current_user)
  end

  it "cancel: should hide [Change Password] form and restore title" do
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('change_password')")
    rendered.should include("crm.set_title('change_password', 'My Profile')")
  end

  it "edit profile: should hide [Edit Profile] and [Upload Avatar] forms and show [Change Password]" do
    render

    rendered.should include("$('#change_password').html")
    rendered.should include("crm.hide_form('edit_profile');")
    rendered.should include("crm.hide_form('upload_avatar');")
    rendered.should include("crm.flip_form('change_password');")
    rendered.should include("crm.set_title('change_password', 'Change Password');")
    rendered.should include("$('#current_password').focus();")
  end

end
