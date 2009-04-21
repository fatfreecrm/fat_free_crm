require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/convert.html.erb" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:lead] = Factory(:lead)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:opportunity] = Factory(:opportunity)
  end

  it "should render [convert lead] form" do
    template.should_receive(:render).with(hash_including(:partial => "leads/opportunity"))
    template.should_receive(:render).with(hash_including(:partial => "leads/convert_permissions"))

    render "/leads/_convert.html.haml"
    response.should have_tag("form[class=edit_lead]")
  end

end


