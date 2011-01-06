require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/index.js.rjs" do
  before do
    login_and_assign
  end

  it "renders [admin/user] template with @users collection" do
    amy = Factory(:user)
    bob = Factory(:user)
    assign(:users, [ amy, bob ].paginate)

    render
    rendered.should have_rjs("users") do |rjs|
      with_tag("li[id=user_#{amy.id}]")
      with_tag("li[id=user_#{bob.id}]")
    end
    rendered.should have_rjs("paginate")
  end

end