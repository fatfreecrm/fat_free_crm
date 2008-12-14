require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/index.html.erb" do
  include CampaignsHelper
  
  before(:each) do
    assigns[:campaigns] = [
      stub_model(Campaign, :status => "Planned"),
      stub_model(Campaign, :status => "Started")
    ]
  end

  it "should render list of campaigns" do
    render "/campaigns/index.html.erb"
  end
end

