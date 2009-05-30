require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/edit.html.erb" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "should render [edit contact] form" do
    assigns[:contact] = Factory(:contact)
    assigns[:users] = [ @current_user ]
    template.should_receive(:render).with(hash_including(:partial => "contacts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/extra"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/web"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/permissions"))

    render "/contacts/_edit.html.haml"
    response.should have_tag("form[class=edit_contact]")
  end

  it "should pick default assignee (Myself)" do
    assigns[:users] = [ @current_user ]
    assigns[:contact] = Factory(:contact, :assignee => nil)

    render "/contacts/_edit.html.haml"
    response.should have_tag("select[id=contact_assigned_to]") do |options|
      options.to_s.should_not include_text(%Q/selected="selected"/)
    end
  end

  it "should show correct assignee" do
    @user = Factory(:user)
    assigns[:users] = [ @current_user, @user ]
    assigns[:contact] = Factory(:contact, :assignee => @user)

    render "/contacts/_edit.html.haml"
    response.should have_tag("select[id=contact_assigned_to]") do |options|
      options.to_s.should include_text(%Q/<option selected="selected" value="#{@user.id}">/)
    end
  end

end


