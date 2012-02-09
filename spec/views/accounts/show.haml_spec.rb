require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/show" do
  include AccountsHelper

  before do
    login_and_assign
    @account = Factory(:account, :id => 42,
      :contacts => [ Factory(:contact) ],
      :opportunities => [ Factory(:opportunity) ])
    assign(:account, @account)
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ Factory(:comment, :commentable => @account) ])
  end

  it "should render account landing page" do
    render

    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")
    view.should render_template(:partial => "contacts/_contact")
    view.should render_template(:partial => "opportunities/_opportunity")

    rendered.should have_tag("div[id=edit_account]")
  end

end

