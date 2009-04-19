require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/accounts/edit.js.rjs" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account, :id => 42, :user => @current_user)
    assigns[:account] = @account
    assigns[:users] = [ @current_user ]
  end

  it "edit: should hide previously open [edit account] for and replace it with account partial" do
    params[:cancel] = nil
    assigns[:previous] = Factory(:account, :id => 41, :user => @current_user)
    
    render "accounts/edit.js.rjs"
    response.should have_rjs("account_41") do |rjs|
      with_tag("li[id=account_41]")
    end
  end

  it "edit from accounts index page: should turn off highlight and replace current account with [edit account] form" do
    params[:cancel] = nil
    
    render "accounts/edit.js.rjs"
    response.body.should include_text('crm.highlight_off("account_42");')
    response.should have_rjs("account_42") do |rjs|
      with_tag("form[class=edit_account]")
    end
  end

  it "edit from account landing page: should show [edit account] form" do
    params[:cancel] = "false"
    
    render "accounts/edit.js.rjs"
    response.should have_rjs("edit_account") do |rjs|
      with_tag("form[class=edit_account]")
    end
    response.body.should include_text('crm.flip_form("edit_account"')
  end

  it "cancel from account landing page: should hide [edit account] form" do
    request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    params[:cancel] = "true"
    
    render "accounts/edit.js.rjs"
    response.body.should include_text('crm.flip_form("edit_account"')
  end

  it "cancel from account index page: should replace [edit account] form with account partial" do
    params[:cancel] = "true"
    
    render "accounts/edit.js.rjs"
    response.should have_rjs("account_42") do |rjs|
      with_tag("li[id=account_42]")
    end
  end

end
