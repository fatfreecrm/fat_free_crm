require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assign(:lead, Factory(:lead, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
  end

  it "should render lead landing page" do
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "common/_timeline")
    view.should render_template(:partial => "common/_tasks")

    render
    rendered.should have_tag("div[id=edit_lead]")
  end

end

