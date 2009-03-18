require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/_edit.html.haml" do
  include CampaignsHelper

  before(:each) do
    @current_user = Factory(:user)
    assigns[:campaign] = Factory(:campaign)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
  end

  it "should render [edit campaign] form" do
    @form = mock("form")
    render "/campaigns/_edit.html.haml"

    response.should have_tag("form[class=edit_campaign]")
  end

end


