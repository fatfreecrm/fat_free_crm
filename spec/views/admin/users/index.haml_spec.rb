require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index.html.haml" do
  include Admin::UsersHelper

  before(:each) do
    login_and_assign(:admin => true)
  end

  it "renders a list of users" do
    assigns[:users] = [ Factory(:user) ].paginate
    template.should_receive(:render).with(hash_including(:partial => "user"))
    template.should_receive(:render).with(:partial => "common/paginate")
    render "/admin/users/index.html.haml"
  end
end
