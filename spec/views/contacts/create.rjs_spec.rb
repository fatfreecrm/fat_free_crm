require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/create.js.rjs" do
  include ContactsHelper

  before(:each) do
    login_and_assign
  end

  it "create (success): should hide [Create Contact] form and insert contact partial" do
    assigns[:contact] = Factory(:contact, :id => 42)
    render "contacts/create.js.rjs"

    response.should have_rjs(:insert, :top) do |rjs|
      with_tag("li[id=contact_42]")
    end
    response.should include_text('$("contact_42").visualEffect("highlight"')
  end

  it "create (success): should refresh sidebar when called from contacts page" do
    assigns[:contact] = Factory(:contact, :id => 42)
    request.env["HTTP_REFERER"] = "http://localhost/contacts"
    render "contacts/create.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
  end

  it "create (success): should update recently viewed items when called outside the contacts (i.e. embedded)" do
    assigns[:contact] = Factory(:contact, :id => 42)
    render "contacts/create.js.rjs"

    response.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]")
    end
  end
 
  it "create (failure): should re-render [create.html.haml] template in :create_contact div" do
    assigns[:contact] = Factory.build(:contact, :first_name => nil) # make it invalid
    @current_user = Factory(:user)
    @account = Factory(:account)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]

    render "contacts/create.js.rjs"

    response.should have_rjs("create_contact") do |rjs|
      with_tag("form[class=new_contact]")
    end
    response.should include_text('visualEffect("shake"')
  end

end


