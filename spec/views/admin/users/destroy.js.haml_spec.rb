# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/users/destroy" do
  before do
    login_admin
  end

  describe "user got deleted" do
    before do
      @user = create(:user)
      @user.destroy
      assign(:user, @user)
    end

    it "blinds up destroyed user partial" do
      render

      expect(rendered).to include('slideUp')
    end
  end

  describe "user was not deleted" do
    before do
      assign(:user, @user = build_stubbed(:user))
    end

    it "should remove confirmation panel" do
      render

      expect(rendered).to include(%/crm.flick('#{dom_id(@user, :confirm)}', 'remove');/)
    end

    it "should shake user partial" do
      render

      expect(rendered).to include(%/$('#user_#{@user.id}').effect('shake'/)
    end

    it "should show flash message" do
      render

      expect(rendered).to include('flash')
      expect(rendered).to include(%/crm.flash('warning')/)
    end
  end
end
