require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/edit.html.erb" do
  include ContactsHelper
  
  before(:each) do
    login
    @account = Factory(:account)
    assigns[:contact] = Factory(:contact)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "should render [edit contact] form" do
    template.should_receive(:render).with(hash_including(:partial => "contacts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/extra"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/web"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/permissions"))

    render "/contacts/_edit.html.haml"
    response.should have_tag("form[class=edit_contact]")
  end

end


