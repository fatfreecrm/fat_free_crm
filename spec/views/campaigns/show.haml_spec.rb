require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/show.html.haml" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    @campaign = Factory(:campaign, :id => 42,
      :leads => [ Factory(:lead) ],
      :opportunities => [ Factory(:opportunity) ])
    assign(:campaign, @campaign)
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ Factory(:comment, :commentable => @campaign) ])
  end

  it "should render campaign landing page" do
    render
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "common/_timeline")
    view.should render_template(:partial => "common/_tasks")

    # XXX: Not rendering due to paginate
    #~ view.should render_template(:partial => "leads/_lead")
    #~ view.should render_template(:partial => "opportunities/_opportunity")

    rendered.should have_tag("div[id=edit_campaign]")
  end

end
