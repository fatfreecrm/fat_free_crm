require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.erb" do
  include LeadsHelper
  before(:each) do
    assigns[:lead]         = stub_model(Lead, :uuid => "12345678-0123-5678-0123-567890123456")
    assigns[:comment]      = stub_model(Comment, :uuid => "87654321-0123-5678-0123-567890123456")
    assigns[:current_user] = stub_model(User)
  end

  it "should render attributes in <p>" do
    render "/leads/show.html.erb"
  end
end

