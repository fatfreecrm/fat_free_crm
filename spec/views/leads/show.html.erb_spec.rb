require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.erb" do
  include LeadsHelper
  before(:each) do
    assigns[:lead] = @lead = stub_model(Lead, :uuid => "12345678-0123-5678-0123-567890123456")
  end

  it "should render attributes in <p>" do
    render "/leads/show.html.erb"
  end
end

