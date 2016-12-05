# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/users/update" do
  before do
    login_and_assign(admin: true)
    assign(:user, @user = FactoryGirl.build_stubbed(:user))
  end

  describe "no errors:" do
    it "replaces [Edit User] form with user partial and highlights it" do
      render

      expect(rendered).to include("user_#{@user.id}")
      expect(rendered).to include(%/$('#user_#{@user.id}').effect("highlight"/)
    end
  end # no errors

  describe "validation errors:" do
    before do
      @user.errors.add(:name)
    end

    it "redraws [Edit User] form and shakes it" do
      render

      expect(rendered).to include("user_#{@user.id}")
      expect(rendered).to include(%/$('#user_#{@user.id}').effect("shake"/)
      expect(rendered).to include(%/$('#user_username').focus()/)
    end
  end # errors
end
