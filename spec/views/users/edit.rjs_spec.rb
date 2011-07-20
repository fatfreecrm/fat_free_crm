require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/users/edit.js.rjs" do
  include UsersHelper
  
  before(:each) do
    login_and_assign
    assign(:user, @user = @current_user)
  end

  it "cancel: should hide [Edit Profile] form and restore title" do
    params[:cancel] = "true"
    
    render
    rendered.should include('crm.flip_form("edit_profile")')
    rendered.should include('crm.set_title("edit_profile", "My Profile")')
  end

  it "edit profile: should hide [Upload Avatar] and [Change Password] forms and show [Edit Profile]" do
    render

    rendered.should have_rjs("edit_profile") do |rjs|
      with_tag("form[class=edit_user]")
    end
    rendered.should include('crm.hide_form("upload_avatar")')
    rendered.should include('crm.hide_form("change_password")')
    rendered.should include('crm.flip_form("edit_profile")')
    rendered.should include('crm.set_title("edit_profile"')
  end

end
