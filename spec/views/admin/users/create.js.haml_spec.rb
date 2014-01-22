# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/create" do
  before do
    login_and_assign(:admin => true)
  end

  describe "create success" do
    before do
      assign(:user, @user = FactoryGirl.create(:user))
      assign(:users, [ @user ]) # .paginate
    end

    it "should hide [Create User] form and insert user partial" do
      render

      rendered.should include(@user.full_name)
      rendered.should include(@user.username)
      rendered.should include(%Q/$('#user_#{@user.id}').effect("highlight"/)
    end

    # it "should update pagination" do
    #   rendered.should include("#paginate")
    # end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_user div" do
      assign(:user, FactoryGirl.build(:user, :username => nil)) # make it invalid
      assign(:users, [ current_user ])
      render

      rendered.should include('Please specify username')
      rendered.should include(%Q/$('#create_user').effect("shake"/)
    end
  end

end
