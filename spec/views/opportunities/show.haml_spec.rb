require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show" do
  include OpportunitiesHelper

  before do
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
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")
    view.should render_template(:partial => "contacts/_contact")

    rendered.should have_tag("div[id=edit_opportunity]")
  end

end

