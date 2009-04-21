require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/accounts/update.js.rjs" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account, :id => 42, :user => @current_user)
    assigns[:account] = @account
    assigns[:users] = [ @current_user ]
  end
 
  it "no errors: should flip [edit_account] form when called from account landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    render "accounts/update.js.rjs"
 
    response.should_not have_rjs("account_42")
    response.should include_text('crm.flip_form("edit_account"')
  end
 
  it "no errors: should replace [edit_account] form with account partial and highligh it when called from account index" do
    request.env["HTTP_REFERER"] = "http://localhost/accounts"
    render "accounts/update.js.rjs"
 
    response.should have_rjs("account_42") do |rjs|
      with_tag("li[id=account_42]")
    end
    response.should include_text('$("account_42").visualEffect("highlight"')
  end

  it "no errors: should update sidebar" do
    render "accounts/update.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
  end
 
  it "errors: should redraw the [edit_account] form and shake it" do
    @account.errors.add(:error)
    render "accounts/update.js.rjs"
 
    response.should have_rjs("account_42") do |rjs|
      with_tag("form[class=edit_account]")
    end
    response.should include_text('$("account_42").visualEffect("shake"')
    response.should include_text('focus()')
  end
 
end