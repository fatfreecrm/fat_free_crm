require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index.html.erb" do
  include LeadsHelper
  
  before(:each) do
    assigns[:leads] = [
      stub_model(Lead),
      stub_model(Lead)
    ]
  end

  it "should render list of leads" do
    render "/leads/index.html.erb"
  end
end

