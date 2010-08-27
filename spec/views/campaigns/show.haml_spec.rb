require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/show.html.haml" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assign(:campaign, Factory(:campaign, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
  end

  it "should render campaign landing page" do
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "common/_timeline")
    view.should render_template(:partial => "common/_tasks")
    view.should render_template(:partial => "leads/_lead")
    view.should render_template(:partial => "opportunities/_opportunity")

    render

    rendered.should have_tag("div[id=edit_campaign]")
  end

end

