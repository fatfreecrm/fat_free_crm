# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/edit" do
  include UsersHelper

  before do
    login
    assign(:user, @user = current_user)
  end

  it "cancel: should hide [Edit Profile] form and restore title" do
    params[:cancel] = "true"

    render
    expect(rendered).to include("crm.flip_form('edit_profile')")
    expect(rendered).to include("crm.set_title('edit_profile', 'My Profile');")
  end

  it "edit profile: should hide [Upload Avatar] and [Change Password] forms and show [Edit Profile]" do
    render

    expect(rendered).to include("$('#edit_profile').html")
    expect(rendered).to include("crm.hide_form('upload_avatar');")
    expect(rendered).to include("crm.hide_form('change_password');")
    expect(rendered).to include("crm.flip_form('edit_profile');")
    expect(rendered).to include("crm.set_title('edit_profile', 'Edit Profile');")
  end
end
