require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/index.html.haml" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
  end

  it "should render list of accounts if list of campaigns is not empty" do
    assign(:campaigns, [ Factory(:campaign) ].paginate)

    render
    view.should render_template(:partial => "_campaign")
    view.should render_template(:partial => "common/_paginate")
  end

  it "should render a message if there're no campaigns" do
    assign(:campaigns, [].paginate)

    render
    view.should_not render_template(:partial => "_campaigns")
    view.should render_template(:partial => "common/_empty")
    view.should render_template(:partial => "common/_paginate")
  end

end
