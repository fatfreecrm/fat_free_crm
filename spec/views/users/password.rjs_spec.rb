require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/users/password.js.rjs" do
  include UsersHelper
  
  before(:each) do
    login_and_assign
    assigns[:user] = @current_user
  end

  it "cancel: should hide [Change Password] form and restore title" do
    params[:cancel] = "true"
    
    render "users/password.js.rjs"
    response.should include_text('crm.flip_form("change_password")')
    response.should include_text('crm.set_title("change_password", "My Profile")')
  end

  it "edit profile: should hide [Edit Profile] and [Upload Avatar] forms and show [Change Password]" do
    render "users/password.js.rjs"

    response.should have_rjs("change_password") do |rjs|
      with_tag("form[class=edit_user]")
    end
    response.should include_text('crm.hide_form("edit_profile")')
    response.should include_text('crm.hide_form("upload_avatar")')
    response.should include_text('crm.flip_form("change_password")')
    response.should include_text('crm.set_title("change_password"')
    response.should include_text('$("current_password").focus()')
  end

end