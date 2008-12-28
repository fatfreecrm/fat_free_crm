require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index.html.erb" do
  include ContactsHelper
  
  before(:each) do
    assigns[:contacts] = [ stub_model(Contact, :uuid => "12345678-0123-5678-0123-567890123456") ]
  end

  it "should render list of contacts" do
    render "/contacts/index.html.erb"
  end
end

