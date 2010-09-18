require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_create.html.haml" do
  include AccountsHelper

  before(:each) do
    login_and_assign
    assign(:account, Account.new)
    assign(:users, [ @current_user ])
  end

  it "should render [create account] form" do
    render

    view.should render_template(:partial => "_top_section")
    view.should render_template(:partial => "_contact_info")
    view.should render_template(:partial => "_permissions")

    rendered.should have_tag("form[class=new_account]")
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :account ]

    render
    rendered.should have_tag("textarea[id=account_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=account_background_info]")
  end

end
