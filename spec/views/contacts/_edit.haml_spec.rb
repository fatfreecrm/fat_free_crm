require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/edit.html.erb" do
  include ContactsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @account = Factory(:account)
    assigns[:contact] = Factory(:contact)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "should render [edit contact] form" do
    @form = mock("form")
    render "/contacts/_edit.html.haml"

    response.should have_tag("form[class=edit_contact]")
  end

end


