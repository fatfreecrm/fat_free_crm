require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/destroy.js.rjs" do
  include Admin::UsersHelper
  
  before(:each) do
    login_and_assign(:admin => true)
  end

  describe "user got deleted" do
    before(:each) do
      assigns[:user] = @user = Factory(:user).destroy
    end

    it "blinds up destroyed user partial" do
      render

      response.should include_text(%Q/$("user_#{@user.id}").visualEffect("blind_up"/)
    end
  end

  describe "user was not deleted" do
    before(:each) do
      assigns[:user] = @user = Factory(:user)
    end

    it "should remove confirmation panel" do
      render

      response.should include_text(%Q/crm.flick("#{dom_id(@user, :confirm)}", "remove");/)
    end

    it "should shake user partial" do
      render

      response.should include_text(%Q/$("user_#{@user.id}").visualEffect("shake"/)
    end

    it "should show flash message" do
      render

      response.should have_rjs("flash")
      response.should include_text('crm.flash("warning")')
    end
  end
end