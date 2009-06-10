require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/new.js.rjs" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:contact] = Contact.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "should toggle empty message div if it exists" do
    render "contacts/new.js.rjs"

    response.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide options form when called from Contacts index" do
    request.env["HTTP_REFERER"] = "http://localhost/contacts"
    render "contacts/new.js.rjs"

    response.should include_text('crm.hide_form("options")')
  end

  describe "new contact" do
    it "should render [new.html.haml] template into :create_contact div" do
      params[:cancel] = nil
      render "contacts/new.js.rjs"
    
      response.should have_rjs("create_contact") do |rjs|
        with_tag("form[class=new_contact]")
      end
    end
  end

  describe "cancel new contact" do
    it "should hide [create contact] form" do
      params[:cancel] = "true"
      render "contacts/new.js.rjs"
    
      response.should_not have_rjs("create_contact")
      response.should include_text('crm.flip_form("create_contact");')
    end
  end

end


