require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assign(:opportunity, Factory(:opportunity, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
  end

  it "should render opportunity landing page" do
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "common/_timeline")
    view.should render_template(:partial => "common/_tasks")
    view.should render_template(:partial => "contacts/_contact")

    render

    rendered.should have_tag("div[id=edit_opportunity]")
  end

end

