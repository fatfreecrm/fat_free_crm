require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/new.html.erb" do
  include ContactsHelper
  
  before(:each) do
    assigns[:contact] = stub_model(Contact, :new_record? => true, :access => "Private")
    assigns[:current_user] = user = mock_model(User, :full_name => "Joe Spec")
    assigns[:users] = [ user ]
    assigns[:account] = stub_model(Account, :user => user, :access => "Private")
    assigns[:accounts] = [ stub_model(Account) ]
  end

  it "should render new form" do
    render "/contacts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", contacts_path) do
    end
  end
end


