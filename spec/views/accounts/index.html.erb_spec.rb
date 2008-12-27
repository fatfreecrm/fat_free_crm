require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index.html.erb" do
  include AccountsHelper
  
  before(:each) do
    assigns[:current_user] = mock_model(User)
    assigns[:accounts] = [
      stub_model(Account, :created_at => Time.now(), :user => mock_model(User, :full_name => "Joe Spec"), :uuid => "12345678-0123-5678-0123-567890123456"),
      stub_model(Account, :created_at => Time.now(), :user => mock_model(User, :full_name => "Joe Spec"), :uuid => "12345678-0123-5678-0123-567890123456")
    ]
  end

  it "should render list of accounts" do
    render "/accounts/index.html.erb"
  end
end

