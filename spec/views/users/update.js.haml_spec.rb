# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/update" do
  include UsersHelper

  before do
    login_and_assign
    assign(:user, @user = current_user)
  end

  describe "no errors:" do
    it "should flip [Edit Profile] form" do
      render
      rendered.should include("crm.flip_form('edit_profile')")
    end

    it "should update Welcome, user!" do
      render
      rendered.should include("jQuery('#welcome_username').html('#{@user.first_name}')")
    end

    it "should update actual user profile information" do
      render
      rendered.should include("jQuery('#profile').html")
    end
  end # no errors

  describe "validation errors :" do
    before do
      @user.errors.add(:first_name)
    end

    it "should redraw the [Edit Profile] form and shake it" do
      render
      rendered.should include("jQuery('#edit_profile').html")
      rendered.should include(%Q/jQuery('#edit_profile').effect("shake"/)
      rendered.should include("jQuery('#user_email').focus();")
    end

  end # errors
end
