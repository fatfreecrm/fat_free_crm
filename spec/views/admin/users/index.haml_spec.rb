require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index.html.haml" do
  include Admin::UsersHelper

  before(:each) do
    login_and_assign(:admin => true)
  end

  it "renders a list of users" do
    assign(:users, [ Factory(:user) ].paginate)
    view.should_receive(:render).with(hash_including(:partial => "user"))
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end
end
