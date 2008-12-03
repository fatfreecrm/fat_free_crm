require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.erb" do
  include LeadsHelper
  before(:each) do
    assigns[:lead] = @lead = stub_model(Lead)
  end

  it "should render attributes in <p>" do
    render "/leads/show.html.erb"
  end
end

