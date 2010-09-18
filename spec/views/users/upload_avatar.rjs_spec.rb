require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/users/upload_avatar.js.rjs" do
  include UsersHelper

  before(:each) do
    login_and_assign
  end

  describe "no errors:" do
    before(:each) do
      @avatar = Factory(:avatar, :entity => @current_user)
      @current_user.stub!(:avatar).and_return(@avatar)
      assign(:user, @user = @current_user)
    end

    it "should flip [Upload Avatar] form" do
      render
      rendered.should_not have_rjs("user_#{@user.id}")
      rendered.should include('crm.flip_form("upload_avatar"')
      rendered.should include('crm.set_title("upload_avatar", "My Profile")')
    end
  end # no errors

  describe "validation errors:" do
    before(:each) do
      @avatar = Factory(:avatar, :entity => @current_user)
      @avatar.errors.add(:image, "error")
      @current_user.stub!(:avatar).and_return(@avatar)
      assign(:user, @user = @current_user)
    end

    it "should redraw the [Upload Avatar] form and shake it" do
      render
      rendered.should have_rjs("upload_avatar") do |rjs|
        with_tag("form[class=edit_user]")
      end
      rendered.should include(%Q/$("upload_avatar").visualEffect("shake"/)
    end
  end # errors
end
