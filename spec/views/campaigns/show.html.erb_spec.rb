require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/show.html.erb" do
  include CampaignsHelper
  before(:each) do
    assigns[:campaign] = @campaign = stub_model(Campaign, :uuid => "12345678-0123-5678-0123-567890123456")
  end

  it "should render attributes in <p>" do
    render "/campaigns/show.html.erb"
  end
end

