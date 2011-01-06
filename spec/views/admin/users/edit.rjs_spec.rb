require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
 
describe "admin/users/edit.js.rjs" do
  before do
    login_and_assign(:admin => true)
    assign(:user, @user = Factory(:user))
  end

  it "cancel replaces [Edit User] form with user partial" do
    params[:cancel] = "true"
    render

    rendered.should have_rjs("user_#{@user.id}") do |rjs|
      with_tag("li[id=user_#{@user.id}]")
    end
  end

  it "edit hides previously open [Edit User] and replaces it with user partial" do
    assign(:previous, previous = Factory(:user))
    render

    rendered.should have_rjs("user_#{previous.id}") do |rjs|
      with_tag("li[id=user_#{previous.id}]")
    end
  end

  it "edit removes previously open [Edit User] if it's no longer available" do
    assign(:previous, previous = 41)
    render

    rendered.should include(%Q/crm.flick("user_#{previous}", "remove");/)
  end

  it "edit turns off highlight, hides [Create User] form, and replaces current user with [Edit User] form" do
    render

    rendered.should include(%Q/crm.highlight_off("user_#{@user.id}");/)
    rendered.should include('crm.hide_form("create_user")')
    rendered.should have_rjs("user_#{@user.id}") do |rjs|
      with_tag("form[class=edit_user]")
    end
  end

end
