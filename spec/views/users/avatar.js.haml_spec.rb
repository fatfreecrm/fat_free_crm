# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/avatar" do
  include UsersHelper

  before do
    login_and_assign
    assign(:user, current_user)
  end

  it "cancel: should hide [Upload Avatar] form and restore title" do
    params[:cancel] = "true"

    render
    rendered.should include("crm.flip_form('upload_avatar')")
    rendered.should include("crm.set_title('upload_avatar', 'My Profile')")
  end

  it "edit profile: should hide [Edit Profile] and [Change Password] forms and show [Upload Avatar]" do
    render

    rendered.should include("$('#upload_avatar').html")
    rendered.should include("crm.hide_form('edit_profile');")
    rendered.should include("crm.hide_form('change_password');")
    rendered.should include("crm.flip_form('upload_avatar');")
    rendered.should include("crm.set_title('upload_avatar', 'Upload Picture');")
  end

end
