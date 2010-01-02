require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/edit.html.erb" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    assigns[:account] = @account = Factory(:account)
    assigns[:accounts] = [ @account ]
  end

  it "should render [edit contact] form" do
    assigns[:contact] = @contact = Factory(:contact)
    assigns[:users] = [ @current_user ]
    template.should_receive(:render).with(hash_including(:partial => "contacts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/extra"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/web"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/permissions"))

    render "/contacts/_edit.html.haml"
    response.should have_tag("form[class=edit_contact]") do
      with_tag "input[type=hidden][id=contact_user_id][value=#{@contact.user_id}]"
    end
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
      with_tag "option[selected=selected]"
      with_tag "option[value=#{@user.id}]"
    end
  end

end


