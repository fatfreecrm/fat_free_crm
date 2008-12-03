require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/show.html.erb" do
  include CampaignsHelper
  before(:each) do
    assigns[:campaign] = @campaign = stub_model(Campaign)
  end

  it "should render attributes in <p>" do
    render "/campaigns/show.html.erb"
  end
end

