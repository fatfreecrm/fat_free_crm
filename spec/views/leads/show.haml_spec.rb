require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show" do
  include LeadsHelper

  before do
    login_and_assign
    assign(:lead, @lead = Factory(:lead, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ Factory(:comment, :commentable => @lead) ])
  end

  it "should render lead landing page" do
    render
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")

    rendered.should have_tag("div[id=edit_lead]")
  end

end

