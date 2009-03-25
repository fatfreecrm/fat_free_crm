require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/_create.html.haml" do
  include AccountsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    assigns[:account] = Account.new
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
  end

  it "should render [create account] form" do
    template.should_receive(:render).with(hash_including(:partial => "accounts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "accounts/contact_info"))
    template.should_receive(:render).with(hash_including(:partial => "accounts/permissions"))

    render "/accounts/_create.html.haml"
    response.should have_tag("form[class=new_account]")
  end
end


