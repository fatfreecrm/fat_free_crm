require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/contacts/update.js.rjs" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account, :id => 987654)
    @contact = Factory(:contact, :id => 42, :user => @current_user)
    assigns[:contact] = @contact
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end
 
  it "no errors: should flip [edit_contact] form when called from contact landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/contacts/123"

    render "contacts/update.js.rjs"
    response.should_not have_rjs("contact_42")
    response.should include_text('crm.flip_form("edit_contact"')
  end

  it "no errors: should update sidebar when called from contact landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/contacts/123"

    render "contacts/update.js.rjs"
    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=summary]")
      with_tag("div[id=recently]")
    end
    response.should include_text('$("summary").visualEffect("shake"')
  end
 
  it "no errors: should replace [Edit Contact] with contact partial and highligh it when called outside contact landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/contacts"

    render "contacts/update.js.rjs"
    response.should have_rjs("contact_42") do |rjs|
      with_tag("li[id=contact_42]")
    end
    response.should include_text('$("contact_42").visualEffect("highlight"')
  end
 
  it "errors: should redraw the [edit_contact] form and shake it" do
    @contact.errors.add(:error)

    render "contacts/update.js.rjs"
    response.should have_rjs("contact_42") do |rjs|
      with_tag("form[class=edit_contact]")
    end
    response.should include_text('crm.create_or_select_account(false)')
    response.should include_text('$("contact_42").visualEffect("shake"')
    response.should include_text('focus()')
  end

  it "errors: should show disabled accounts dropdown when called from accounts landing page" do
    @contact.errors.add(:error)
    request.env["HTTP_REFERER"] = ref = "http://localhost/accounts/123"

    render "contacts/update.js.rjs"
    response.should include_text("crm.create_or_select_account(#{ref =~ /\/accounts\//})")
  end

end