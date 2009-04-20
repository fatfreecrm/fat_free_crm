require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/edit.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:opportunity] = Factory(:opportunity)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "should render [edit opportunity] form" do
    @form = mock("form")
    render "/opportunities/_edit.html.haml"

    response.should have_tag("form[class=edit_opportunity]")
  end

end


