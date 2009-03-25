require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/_create.html.haml" do
  include ContactsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @account = Factory(:account)
    assigns[:contact] = Contact.new
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:account] = @account
    assigns[:contacts] = [ @account ]
  end

  it "should render [create contact] form" do
    template.should_receive(:render).with(hash_including(:partial => "contacts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/extra"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/web"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/permissions"))

    render "/contacts/_create.html.haml"
    response.should have_tag("form[class=new_contact]")
  end
end


