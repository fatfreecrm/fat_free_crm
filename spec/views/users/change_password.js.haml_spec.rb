# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/change_password" do
  include UsersHelper

  before do
    login_and_assign
    assign(:user, @user = current_user)
  end

  describe "no errors:" do
    it "should flip [Change Password] form" do
      render

      rendered.should_not include("user_#{@user.id}")
      rendered.should include("crm.flip_form('change_password');")
      rendered.should include("crm.set_title('change_password', 'My Profile');")
    end

    it "should show flash message" do
      render

      rendered.should include("#flash")
      rendered.should include("crm.flash('notice')")
    end
  end # no errors

  describe "validation errors:" do
    it "should redraw the [Change Password] form and shake it" do
      @user.errors.add(:current_password, "error")
      render

      rendered.should include("$('#change_password').html")
      rendered.should include(%Q/$('#change_password').effect("shake"/)
      rendered.should include("$('#current_password').focus();")
    end

    it "should redraw the [Change Password] form and correctly set focus" do
      @user.errors.add(:user_password, "error")
      render

      rendered.should include("$('#user_password').focus();")
    end

  end # errors
end
