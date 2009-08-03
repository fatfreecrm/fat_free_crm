require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/_create.html.haml" do
  include Admin::UsersHelper
  
  before(:each) do
    login_and_assign(:admin => true)
    assigns[:user] = User.new
    assigns[:users] = [ @current_user ]
  end

  it "renders [Create User] form" do
    template.should_receive(:render).with(hash_including(:partial => "admin/users/profile"))

    render "admin/users/_create.html.haml"
    response.should have_tag("form[class=new_user]")
  end
end


