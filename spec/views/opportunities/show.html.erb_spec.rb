require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show.html.erb" do
  include OpportunitiesHelper
  before(:each) do
    assigns[:opportunity] = @opportunity = stub_model(Opportunity, :uuid => "12345678-0123-5678-0123-567890123456")
  end

  it "should render attributes in <p>" do
    render "/opportunities/show.html.erb"
  end
end

