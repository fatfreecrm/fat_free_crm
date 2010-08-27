require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/index.html.haml" do
  include CampaignsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render list of accounts if list of campaigns is not empty" do
    assign(:campaigns, [ Factory(:campaign) ])
    view.should render_template(:partial => "_campaign")
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

  it "should render a message if there're no campaigns" do
    assign(:campaigns, [])
    view.should_not_receive(:render).with(hash_including(:partial => "campaigns"))
    view.should_receive(:render).with(:partial => "common/empty")
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

end

