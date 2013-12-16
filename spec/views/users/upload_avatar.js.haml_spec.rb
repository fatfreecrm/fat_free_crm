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
      @avatar = FactoryGirl.create(:avatar, :entity => current_user)
      current_user.stub(:avatar).and_return(@avatar)
      assign(:user, @user = current_user)
    end

    it "should flip [Upload Avatar] form" do
      render
      rendered.should_not include("user_#{@user.id}")
      rendered.should include("crm.flip_form('upload_avatar'")
      rendered.should include("crm.set_title('upload_avatar', 'My Profile')")
    end
  end # no errors

  describe "validation errors:" do
    before do
      @avatar = FactoryGirl.create(:avatar, :entity => current_user)
      @avatar.errors.add(:image, "error")
      current_user.stub(:avatar).and_return(@avatar)
      assign(:user, @user = current_user)
    end

    it "should redraw the [Upload Avatar] form and shake it" do
      render
      rendered.should include("$('#upload_avatar').html")
      rendered.should include(%Q/$('#upload_avatar').effect("shake"/)
    end
  end # errors
end
