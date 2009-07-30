require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/edit.html.haml" do
  include Admin::UsersHelper

  before(:each) do
    assigns[:user] = @user = stub_model(User, :new_record? => false)
  end

  it "renders the edit users form" do
    render

    response.should have_tag("form[action=#{admin_user_path(@user)}][class=edit_user]") do
    end
  end
end
