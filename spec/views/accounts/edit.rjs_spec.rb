require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/accounts/edit.js.rjs" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
    assign(:account, @account = Factory(:account, :user => @current_user))
    assign(:users, [ @current_user ])
  end

  it "cancel from accounts index page: should replace [Edit Account] form with account partial" do
    params[:cancel] = "true"
    
    render
    rendered.should have_rjs("account_#{@account.id}") do |rjs|
      with_tag("li[id=account_#{@account.id}]")
    end
  end

  it "cancel from account landing page: should hide [Edit Account] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    params[:cancel] = "true"
    
    render
    rendered.should include('crm.flip_form("edit_account"')
  end

  it "edit: should hide previously open [Edit Account] for and replace it with account partial" do
    params[:cancel] = nil
    assign(:previous, previous = Factory(:account, :user => @current_user))
    
    render
    rendered.should have_rjs("account_#{previous.id}") do |rjs|
      with_tag("li[id=account_#{previous.id}]")
    end
  end

  it "edit: should remove previously open [Edit Account] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include(%Q/crm.flick("account_#{previous}", "remove");/)
  end

  it "edit from accounts index page: should turn off highlight, hide [Create Account] form, and replace current account with [edit account] form" do
    params[:cancel] = nil
    
    render
    rendered.should include(%Q/crm.highlight_off("account_#{@account.id}");/)
    rendered.should include('crm.hide_form("create_account")')
    rendered.should have_rjs("account_#{@account.id}") do |rjs|
      with_tag("form[class=edit_account]")
    end
  end

  it "edit from account landing page: should show [edit account] form" do
    params[:cancel] = "false"
    
    render
    rendered.should have_rjs("edit_account") do |rjs|
      with_tag("form[class=edit_account]")
    end
    rendered.should include('crm.flip_form("edit_account"')
  end

end
