require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/new.html.haml" do
  include Admin::UsersHelper

  before(:each) do
    assigns[:user] = stub_model(User, :new_record? => true)
  end

  it "renders new users form" do
    render

    response.should have_tag("form[action=#{admin_users_path}][class=new_user]") do
    end
  end
end
