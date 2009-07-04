require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/users/upload_avatar.js.rjs" do
  include UsersHelper

  before(:each) do
    login_and_assign
  end

  describe "no errors:" do
    before(:each) do
      assigns[:user] = @user = @current_user
    end

    it "should flip [Upload Avatar] form" do
      render "users/upload_avatar.js.rjs"
      # response.should_not have_rjs("user_#{@user.id}")
      # response.should include_text('crm.flip_form("upload_avatar"')
    end
  end # no errors
  
  describe "validation errors:" do
    before(:each) do
      assigns[:user] = @user = Factory(:user)
    end

    it "should redraw the [Upload Avatar] form and shake it" do
      # render "users/upload_avatar.js.rjs"
      # response.should have_rjs("upload_avatar") do |rjs|
      #   with_tag("form[class=upload_avatar]")
      # end
      # response.should include_text(%Q/$("upload_avatar").visualEffect("shake"/)
    end
  end # errors
end