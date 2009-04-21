require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/contacts/edit.js.rjs" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:contact] = Factory(:contact, :id => 42, :user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end

  it "cancel from contact index page: should replace [Edit Contact] form with contact partial" do
    params[:cancel] = "true"
    
    render "contacts/edit.js.rjs"
    response.should have_rjs("contact_42") do |rjs|
      with_tag("li[id=contact_42]")
    end
  end

  it "cancel from contact landing page: should hide [Edit Contact] form" do
    request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
    params[:cancel] = "true"
    
    render "contacts/edit.js.rjs"
    response.should include_text('crm.flip_form("edit_contact"')
  end

  it "edit: should hide previously open [Edit Contact] for and replace it with contact partial" do
    params[:cancel] = nil
    assigns[:previous] = Factory(:contact, :id => 41, :user => @current_user)
    
    render "contacts/edit.js.rjs"
    response.should have_rjs("contact_41") do |rjs|
      with_tag("li[id=contact_41]")
    end
  end
  
  it "edit from contacts index page: should turn off highlight and replace current contact with [Edit Contact] form" do
    params[:cancel] = nil
    
    render "contacts/edit.js.rjs"
    response.should include_text('crm.highlight_off("contact_42");')
    response.should have_rjs("contact_42") do |rjs|
      with_tag("form[class=edit_contact]")
    end
  end
  
  it "edit from contact landing page: should show [Edit Contact] form" do
    params[:cancel] = "false"
    
    render "contacts/edit.js.rjs"
    response.should have_rjs("edit_contact") do |rjs|
      with_tag("form[class=edit_contact]")
    end
    response.should include_text('crm.flip_form("edit_contact"')
  end
  
  it "should show handle new or existing account for the contact" do

    render "contacts/edit.js.rjs"
    response.should include_text("crm.create_or_select_account")
  end

end
