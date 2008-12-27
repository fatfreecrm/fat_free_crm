require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/index.html.erb" do
  include CampaignsHelper
  
  before(:each) do
    assigns[:campaigns] = [
      stub_model(Campaign, :status => "Planned", :uuid => "12345678-0123-5678-0123-567890123456"),
      stub_model(Campaign, :status => "Started", :uuid => "12345678-0123-5678-0123-567890123456")
    ]
    Setting.stub!(:campaign_status_color).and_return({ :key => "value" })
    Setting.stub!(:campaign_status).and_return({ :key => "value" })
  end

  it "should render list of campaigns" do
    render "/campaigns/index.html.erb"
  end
end

