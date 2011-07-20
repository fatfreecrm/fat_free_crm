require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/contacts/edit.js.rjs" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    assign(:contact, @contact = Factory(:contact, :user => @current_user))
    assign(:users, [ @current_user ])
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
  end

  it "cancel from contact index page: should replace [Edit Contact] form with contact partial" do
    params[:cancel] = "true"
    
    render
    rendered.should have_rjs("contact_#{@contact.id}") do |rjs|
      with_tag("li[id=contact_#{@contact.id}]")
    end
  end

  it "cancel from contact landing page: should hide [Edit Contact] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
    params[:cancel] = "true"
    
    render
    rendered.should include('crm.flip_form("edit_contact"')
  end

  it "edit: should hide previously open [Edit Contact] for and replace it with contact partial" do
    params[:cancel] = nil
    assign(:previous, previous = Factory(:contact, :user => @current_user))
    
    render
    rendered.should have_rjs("contact_#{previous.id}") do |rjs|
      with_tag("li[id=contact_#{previous.id}]")
    end
  end

  it "edit: should hide and remove previously open [Edit Contact] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include(%Q/crm.flick("contact_#{previous}", "remove");/)
  end
  
  it "edit from contacts index page: should turn off highlight, hide [Create Contact] form, and replace current contact with [Edit Contact] form" do
    params[:cancel] = nil
    
    render
    rendered.should include(%Q/crm.highlight_off("contact_#{@contact.id}");/)
    rendered.should include('crm.hide_form("create_contact")')
    rendered.should have_rjs("contact_#{@contact.id}") do |rjs|
      with_tag("form[class=edit_contact]")
    end
  end
  
  it "edit from contact landing page: should show [Edit Contact] form" do
    params[:cancel] = "false"
    
    render
    rendered.should have_rjs("edit_contact") do |rjs|
      with_tag("form[class=edit_contact]")
    end
    rendered.should include('crm.flip_form("edit_contact"')
  end
  
  it "should show handle new or existing account for the contact" do

    render
    rendered.should include("crm.create_or_select_account")
  end

end
