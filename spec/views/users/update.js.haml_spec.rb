# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/update" do
  include UsersHelper

  before do
    login
    assign(:user, @user = current_user)
  end

  describe "no errors:" do
    it "should flip [Edit Profile] form" do
      render
      expect(rendered).to include("crm.flip_form('edit_profile')")
    end

    it "should update Welcome, user!" do
      render
      expect(rendered).to include("$('#welcome_username').html('#{@user.first_name}')")
    end

    it "should update actual user profile information" do
      render
      expect(rendered).to include("$('#profile').html")
    end
  end

  describe "validation errors :" do
    before do
      @user.errors.add(:first_name)
    end

    it "should redraw the [Edit Profile] form" do
      render
      expect(rendered).to include("$('#edit_profile').html")
      expect(rendered).to include("$('#user_email').focus();")
    end
  end
end
