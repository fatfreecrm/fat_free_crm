# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/users/new" do
  before do
    login_and_assign(:admin => true)
    assign(:user, User.new)
  end

  describe "new user" do
    it "shows [create user] form" do
      params[:cancel] = nil
      render

      rendered.should include("$('#create_user').html")
    end
  end

  describe "cancel new user" do
    it "hides [create user] form" do
      params[:cancel] = "true"
      render

      rendered.should include("crm.set_title('create_user', 'Users');")
      rendered.should include("crm.flip_form('create_user');")
    end
  end

end

