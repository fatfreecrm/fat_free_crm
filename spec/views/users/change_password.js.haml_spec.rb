# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/change_password" do
  include UsersHelper

  before do
    login
    assign(:user, @user = current_user)
  end

  describe "no errors:" do
    it "should flip [Change Password] form" do
      render

      expect(rendered).not_to include("user_#{@user.id}")
      expect(rendered).to include("crm.flip_form('change_password');")
      expect(rendered).to include("crm.set_title('change_password', 'My Profile');")
    end

    it "should show flash message" do
      render

      expect(rendered).to include("#flash")
      expect(rendered).to include("crm.flash('notice')")
    end
  end

  describe "validation errors:" do
    it "should redraw the [Change Password] form and shake it" do
      @user.errors.add(:current_password, "error")
      render

      expect(rendered).to include("$('#change_password').html")
      expect(rendered).to include(%/$('#change_password').effect("shake"/)
      expect(rendered).to include("$('#current_password').focus();")
    end

    it "should redraw the [Change Password] form and correctly set focus" do
      @user.errors.add(:user_password, "error")
      render

      expect(rendered).to include("$('#user_password').focus();")
    end
  end
end
