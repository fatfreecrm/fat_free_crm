require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/_create.html.haml" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assign(:campaign, Campaign.new)
    assign(:users, [ @current_user ])
  end

  it "should render [create campaign] form" do
    render
    view.should render_template(:partial => "campaigns/_top_section")
    view.should render_template(:partial => "campaigns/_objectives")
    view.should render_template(:partial => "campaigns/_permissions")

    rendered.should have_tag("form[class=new_campaign]")
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :campaign ]

    render
    rendered.should have_tag("textarea[id=campaign_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=campaign_background_info]")
  end
end
