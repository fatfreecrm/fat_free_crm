require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/_create.html.haml" do
  include ContactsHelper

  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assign(:contact, Contact.new)
    assign(:users, [ @current_user ])
    assign(:account, @account)
    assign(:accounts, [ @account ])
  end

  it "should render [create contact] form" do
    render
    view.should render_template(:partial => "contacts/_top_section")
    view.should render_template(:partial => "contacts/_extra")
    view.should render_template(:partial => "contacts/_web")
    view.should render_template(:partial => "contacts/_permissions")

    rendered.should have_tag("form[class=new_contact]")
  end

  it "should pick default assignee (Myself)" do
    render
    rendered.should have_tag("select[id=contact_assigned_to]") do |options|
      options.to_s.should_not include(%Q/selected="selected"/)
    end
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :contact ]

    render
    rendered.should have_tag("textarea[id=contact_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=contact_background_info]")
  end

end
