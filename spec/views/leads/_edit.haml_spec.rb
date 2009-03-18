require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/edit.html.erb" do
  include LeadsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @campaign = Factory(:campaign)
    assigns[:lead] = Factory(:lead)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:campaign] = @campaign
    assigns[:campaigns] = [ @campaign ]
  end

  it "should render [edit lead] form" do
    @form = mock("form")
    render "/leads/_edit.html.haml"

    response.should have_tag("form[class=edit_lead]")
  end

end


