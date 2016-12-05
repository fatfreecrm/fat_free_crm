# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/users/upload_avatar" do
  include UsersHelper

  before do
    login_and_assign
  end

  describe "no errors:" do
    before do
      @avatar = FactoryGirl.build_stubbed(:avatar, entity: current_user)
      allow(current_user).to receive(:avatar).and_return(@avatar)
      assign(:user, @user = current_user)
    end

    it "should flip [Upload Avatar] form" do
      render
      expect(rendered).not_to include("user_#{@user.id}")
      expect(rendered).to include("crm.flip_form('upload_avatar'")
      expect(rendered).to include("crm.set_title('upload_avatar', 'My Profile')")
    end
  end # no errors

  describe "validation errors:" do
    before do
      @avatar = FactoryGirl.build_stubbed(:avatar, entity: current_user)
      @avatar.errors.add(:image, "error")
      allow(current_user).to receive(:avatar).and_return(@avatar)
      assign(:user, @user = current_user)
    end

    it "should redraw the [Upload Avatar] form and shake it" do
      render
      expect(rendered).to include("$('#upload_avatar').html")
      expect(rendered).to include(%/$('#upload_avatar').effect("shake"/)
    end
  end # errors
end
