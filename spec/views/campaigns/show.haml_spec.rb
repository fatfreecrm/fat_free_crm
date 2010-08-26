require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/show.html.haml" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assigns[:campaign] = Factory(:campaign, :id => 42)
    assigns[:users] = [ @current_user ]
    assigns[:comment] = Comment.new
  end

  it "should render campaign landing page" do
    view.should_receive(:render).with(hash_including(:partial => "comments/new"))
    view.should_receive(:render).with(hash_including(:partial => "common/timeline"))
    view.should_receive(:render).with(hash_including(:partial => "common/tasks"))
    view.should_receive(:render).with(hash_including(:partial => "leads/lead"))
    view.should_receive(:render).with(hash_including(:partial => "opportunities/opportunity"))

    render

    rendered.should have_tag("div[id=edit_campaign]")
  end

end

