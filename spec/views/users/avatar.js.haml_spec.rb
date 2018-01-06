# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/avatar" do
  include UsersHelper

  before do
    login
    assign(:user, current_user)
  end

  it "cancel: should hide [Upload Avatar] form and restore title" do
    params[:cancel] = "true"

    render
    expect(rendered).to include("crm.flip_form('upload_avatar')")
    expect(rendered).to include("crm.set_title('upload_avatar', 'My Profile')")
  end

  it "edit profile: should hide [Edit Profile] and [Change Password] forms and show [Upload Avatar]" do
    render

    expect(rendered).to include("$('#upload_avatar').html")
    expect(rendered).to include("crm.hide_form('edit_profile');")
    expect(rendered).to include("crm.hide_form('change_password');")
    expect(rendered).to include("crm.flip_form('upload_avatar');")
    expect(rendered).to include("crm.set_title('upload_avatar', 'Upload Picture');")
  end
end
