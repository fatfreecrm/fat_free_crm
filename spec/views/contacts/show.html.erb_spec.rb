require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/show.html.erb" do
  include ContactsHelper
  before(:each) do
    assigns[:contact] = @contact = stub_model(Contact, :uuid => "12345678-0123-5678-0123-567890123456")
  end

  it "should render attributes in <p>" do
    render "/contacts/show.html.erb"
  end
end

