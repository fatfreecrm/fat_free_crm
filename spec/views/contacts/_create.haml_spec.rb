require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/_create.html.haml" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:contact] = Contact.new
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "should render [create contact] form" do
    template.should_receive(:render).with(hash_including(:partial => "contacts/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/comment"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/tags"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/extra"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/web"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/permissions"))

    render "/contacts/_create.html.haml"
    response.should have_tag("form[class=new_contact]")
  end

  it "should pick default assignee (Myself)" do
    render "/contacts/_create.html.haml"
    response.should have_tag("select[id=contact_assigned_to]") do |options|
      with_tag "option[selected=selected]"
      with_tag "option[value=#{@current_user.id}]"
    end
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :contact ]

    render "/contacts/_create.html.haml"
    response.should have_tag("textarea[id=contact_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render "/contacts/_create.html.haml"
    response.should_not have_tag("textarea[id=contact_background_info]")
  end
end


