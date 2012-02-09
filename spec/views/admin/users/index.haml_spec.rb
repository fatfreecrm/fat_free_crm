require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index" do
  before do
    login_and_assign(:admin => true)
  end

  it "renders a list of users" do
    assign(:users, [ Factory(:user) ].paginate)

    render
    view.should render_template(:partial => "_user")
    view.should render_template(:partial => "shared/_paginate")
  end
end

