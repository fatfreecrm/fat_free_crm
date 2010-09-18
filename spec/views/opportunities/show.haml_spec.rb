require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    @opportunity = Factory(:opportunity, :id => 42,
      :contacts => [ Factory(:contact) ])
    assign(:opportunity, @opportunity)
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ Factory(:comment, :commentable => @opportunity) ])
  end

  it "should render opportunity landing page" do
    render
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "common/_timeline")
    view.should render_template(:partial => "common/_tasks")
    view.should render_template(:partial => "contacts/_contact")

    rendered.should have_tag("div[id=edit_opportunity]")
  end

end
