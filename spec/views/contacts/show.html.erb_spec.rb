require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/show.html.erb" do
  include ContactsHelper
  before(:each) do
    assigns[:contact]      = stub_model(Contact, :uuid => "12345678-0123-5678-0123-567890123456")
    assigns[:comment]      = stub_model(Comment, :uuid => "87654321-0123-5678-0123-567890123456")
    assigns[:current_user] = stub_model(User)
  end

  it "should render attributes in <p>" do
    render "/contacts/show.html.erb"
  end
end

