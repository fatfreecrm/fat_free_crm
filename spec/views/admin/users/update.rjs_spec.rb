require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/update.js.rjs" do
  include Admin::UsersHelper
  
  before(:each) do
    login_and_assign(:admin => true)
    assigns[:user] = @user = Factory(:user)
  end

  describe "no errors:" do
    it "replaces [Edit User] form with user partial and highlights it" do
      render

      response.should have_rjs("user_#{@user.id}") do |rjs|
        with_tag("li[id=user_#{@user.id}]")
      end
      response.should include_text(%Q/$("user_#{@user.id}").visualEffect("highlight"/)
    end
  end # no errors

  describe "validation errors:" do
    before(:each) do
      @user.errors.add(:error)
    end

    it "redraws [Edit User] form and shakes it" do
      render

      response.should have_rjs("user_#{@user.id}") do |rjs|
        with_tag("form[class=edit_user]")
      end
      response.should include_text(%Q/$("user_#{@user.id}").visualEffect("shake"/)
      response.should include_text('$("user_username").focus()')
    end
  end # errors
end