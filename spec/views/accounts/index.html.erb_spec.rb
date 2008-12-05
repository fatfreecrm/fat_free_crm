require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index.html.erb" do
  include AccountsHelper
  
  before(:each) do
    assigns[:accounts] = [
      stub_model(Account, :created_at => Time.now()),
      stub_model(Account, :created_at => Time.now())
    ]
  end

  it "should render list of accounts" do
    render "/accounts/index.html.erb"
  end
end

