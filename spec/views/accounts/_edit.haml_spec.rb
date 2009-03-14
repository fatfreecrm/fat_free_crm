require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_edit.html.haml" do
  include AccountsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    assigns[:account] = Factory(:account, :id => 42)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
  end

  it "should render [edit account] form" do
    @form = mock("form")
    render "/accounts/_edit.html.haml"

    response.should have_tag("form[class=edit_account]")
  end
end


