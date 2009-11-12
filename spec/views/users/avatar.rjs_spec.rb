require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/users/avatar.js.rjs" do
  include UsersHelper
  
  before(:each) do
    login_and_assign
    assigns[:user] = @current_user
  end

  it "cancel: should hide [Upload Avatar] form and restore title" do
    params[:cancel] = "true"
    
    render "users/avatar.js.rjs"
    response.should include_text('crm.flip_form("upload_avatar")')
    response.should include_text('crm.set_title("upload_avatar", "My Profile")')
  end

  it "edit profile: should hide [Edit Profile] and [Change Password] forms and show [Upload Avatar]" do
    render "users/avatar.js.rjs"

    response.should have_rjs("upload_avatar") do |rjs|
      with_tag("form[class=edit_user]")
    end
    response.should include_text('crm.hide_form("edit_profile")')
    response.should include_text('crm.hide_form("change_password")')
    response.should include_text('crm.flip_form("upload_avatar")')
    response.should include_text('crm.set_title("upload_avatar"')
  end

end
