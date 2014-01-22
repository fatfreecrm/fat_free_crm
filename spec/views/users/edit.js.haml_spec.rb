# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/edit" do
  include UsersHelper

  before do
    login_and_assign
    assign(:user, @user = current_user)
  end

  it "cancel: should hide [Edit Profile] form and restore title" do
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('edit_profile')")
    rendered.should include("crm.set_title('edit_profile', 'My Profile');")
  end

  it "edit profile: should hide [Upload Avatar] and [Change Password] forms and show [Edit Profile]" do
    render

    rendered.should include("$('#edit_profile').html")
    rendered.should include("crm.hide_form('upload_avatar');")
    rendered.should include("crm.hide_form('change_password');")
    rendered.should include("crm.flip_form('edit_profile');")
    rendered.should include("crm.set_title('edit_profile', 'Edit Profile');")
  end

end
