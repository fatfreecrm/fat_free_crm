require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/update.js.rjs" do
  include UsersHelper

  before(:each) do
    login_and_assign
    assign(:user, @user = @current_user)
  end

  describe "no errors:" do
    it "should flip [Edit Profile] form" do
      render
      rendered.should include('crm.flip_form("edit_profile")')
    end

    it "should update Welcome, user!" do
      render
      rendered.should have_rjs("welcome_username")
    end

    it "should update actual user profile information" do
      render
      rendered.should have_rjs("profile")
    end
  end # no errors

  describe "validation errors :" do
    before(:each) do
      @user.errors.add(:first_name)
    end

    it "should redraw the [Edit Profile] form and shake it" do
      render
      rendered.should have_rjs("edit_profile") do |rjs|
        with_tag("form[class=edit_user]")
      end
      rendered.should include('$("edit_profile").visualEffect("shake"')
      rendered.should include('$("user_email").focus()')
    end

    it "should keep welcome or profile information intact" do
      render
      rendered.should_not have_rjs("welcome_username")
      rendered.should_not have_rjs("profile")
    end

  end # errors
end
