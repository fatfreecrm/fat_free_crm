require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/show.html.erb" do
  include AccountsHelper
  before(:each) do
    assigns[:account] = @account = stub_model(Account, :uuid => "12345678-0123-5678-0123-567890123456")
  end

  it "should render attributes in <p>" do
    render "/accounts/show.html.erb"
  end
end

