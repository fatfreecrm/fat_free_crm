require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/index.js.rjs" do
  include CampaignsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render [campaign] template with @campaigns collection if there are campaigns" do
    assigns[:campaigns] = [ Factory(:campaign, :id => 42) ].paginate

    render "/campaigns/index.js.rjs"
    response.should have_rjs("campaigns") do |rjs|
      with_tag("li[id=campaign_#{42}]")
    end
    response.should have_rjs("paginate")
  end

  it "should render [empty] template if @campaigns collection if there are no campaigns" do
    assigns[:campaigns] = [].paginate

    render "/campaigns/index.js.rjs"
    response.should have_rjs("campaigns") do |rjs|
      with_tag("div[id=empty]")
    end
    response.should have_rjs("paginate")
  end

end