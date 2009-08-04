require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/edit.html.haml" do
  include Admin::UsersHelper

  before(:each) do
    login_and_assign(:admin => true)
    assigns[:user] = @user = Factory(:user)
  end

  it "renders the edit user form" do
    render
    response.should have_tag("form[action=#{admin_user_path(@user)}][class=edit_user]")
  end
end
