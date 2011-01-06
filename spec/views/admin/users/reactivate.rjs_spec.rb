require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/reactivate.js.rjs" do
  before do
    login_and_assign(:admin => true)
    assign(:user, @user = Factory(:user, :suspended_at => Time.now.yesterday))
  end

  it "reloads the requested user partial" do
    render

    rendered.should have_rjs("user_#{@user.id}") do |rjs|
      with_tag("li[id=user_#{@user.id}]")
    end
    rendered.should include(%Q/$("user_#{@user.id}").visualEffect("highlight"/)
  end
end