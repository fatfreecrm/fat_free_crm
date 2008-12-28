require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    assigns[:opportunities] = [ stub_model(Opportunity, :uuid => "12345678-0123-5678-0123-567890123456") ]
  end

  it "should render list of opportunities" do
    render "/opportunities/index.html.erb"
  end
end

