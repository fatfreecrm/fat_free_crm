require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/suspend.js.rjs" do
  include Admin::UsersHelper

  before(:each) do
    login_and_assign(:admin => true)
    assigns[:user] = @user = Factory(:user, :suspended_at => nil)
  end

  it "reloads the requested user partial" do
    render "admin/users/suspend.js.rjs"

    response.should have_rjs("user_#{@user.id}") do |rjs|
      with_tag("li[id=user_#{@user.id}]")
    end
    response.should include_text(%Q/$("user_#{@user.id}").visualEffect("highlight"/)
  end
end