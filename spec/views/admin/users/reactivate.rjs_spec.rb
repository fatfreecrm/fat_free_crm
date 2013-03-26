# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/reactivate" do
  before do
    login_and_assign(:admin => true)
    assign(:user, @user = FactoryGirl.create(:user, :suspended_at => Time.now.yesterday))
  end

  it "reloads the requested user partial" do
    render

    rendered.should have_rjs("user_#{@user.id}") do |rjs|
      with_tag("li[id=user_#{@user.id}]")
    end
    rendered.should include(%Q/$("user_#{@user.id}").visualEffect("highlight"/)
  end
end
