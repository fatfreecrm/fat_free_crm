require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/show" do
  include ContactsHelper

  before do
    login_and_assign
    @contact = Factory(:contact, :id => 42,
      :opportunities => [ Factory(:opportunity) ])
    assign(:contact, @contact)
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ Factory(:comment, :commentable => @contact) ])
  end

  it "should render contact landing page" do
    render
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")
    view.should render_template(:partial => "opportunities/_opportunity")

    rendered.should have_tag("div[id=edit_contact]")
  end

end

