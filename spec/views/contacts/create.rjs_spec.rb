require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/create.js.rjs" do
  include ContactsHelper
  before(:each) do
    login
  end

  it "create (success): should hide [Create Contact] form and insert contact partial" do
    assigns[:contact] = Factory(:contact, :id => 42)
    render "contacts/create.js.rjs"

    response.should have_rjs(:insert, :top) do |rjs|
      with_tag("li[id=contact_42]")
    end
    response.should include_text('$("contact_42").visualEffect("highlight"')
  end

  it "create (success): should refresh sidebar" do
    assigns[:contact] = Factory(:contact, :id => 42)
    render "contacts/create.js.rjs"

    response.should include_text("Recent Items")
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


