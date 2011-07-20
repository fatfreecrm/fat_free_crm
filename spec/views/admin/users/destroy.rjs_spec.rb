require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/destroy.js.rjs" do
  before do
    login_and_assign(:admin => true)
  end

  describe "user got deleted" do
    before(:each) do
      @user = Factory(:user)
      @user.destroy
      assign(:user, @user)
    end

    it "blinds up destroyed user partial" do
      render

      rendered.should include(%Q/$("user_#{@user.id}").visualEffect("blind_up"/)
    end
  end

  describe "user was not deleted" do
    before(:each) do
      assign(:user, @user = Factory(:user))
    end

    it "should remove confirmation panel" do
      render

      rendered.should include(%Q/crm.flick("#{dom_id(@user, :confirm)}", "remove");/)
    end

    it "should shake user partial" do
      render

      rendered.should include(%Q/$("user_#{@user.id}").visualEffect("shake"/)
    end

    it "should show flash message" do
      render

      rendered.should have_rjs("flash")
      rendered.should include('crm.flash("warning")')
    end
  end
end
