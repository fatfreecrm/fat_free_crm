require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/users/change_password.js.rjs" do
  include UsersHelper

  before(:each) do
    login_and_assign
    assign(:user, @user = @current_user)
  end

  describe "no errors:" do
    it "should flip [Change Password] form" do
      render

      rendered.should_not have_rjs("user_#{@user.id}")
      rendered.should include('crm.flip_form("change_password"')
      rendered.should include('crm.set_title("change_password", "My Profile")')
    end

    it "should show flash message" do
      render

      rendered.should have_rjs("flash")
      rendered.should include('crm.flash("notice")')
    end
  end # no errors

  describe "validation errors:" do
    it "should redraw the [Change Password] form and shake it" do
      @user.errors.add(:current_password, "error")
      render

      rendered.should have_rjs("change_password") do |rjs|
        with_tag("form[class=edit_user]")
      end
      rendered.should include('$("change_password").visualEffect("shake"')
      rendered.should include('$("current_password").focus()')
    end

    it "should redraw the [Change Password] form and correctly set focus" do
      @user.errors.add(:user_password, "error")
      render

      rendered.should include('$("user_password").focus()')
    end

  end # errors
end
