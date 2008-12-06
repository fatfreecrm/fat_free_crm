require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/new.html.erb" do
  include AccountsHelper
  
  before(:each) do
    assigns[:current_user] = stub_model(User)
    assigns[:account] = stub_model(Account, :new_record? => true)
    assigns[:users] = [ stub_model(User) ]
  end

  it "should render new form" do
    render "/accounts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", accounts_path) do
    end
  end
end


