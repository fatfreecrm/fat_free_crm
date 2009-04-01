require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/accounts/new.js.rjs" do
  include AccountsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    assigns[:account] = Account.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
  end
 
  it "create: should render [new.html.haml] template into :create_account div" do
    params[:cancel] = nil
    render "accounts/new.js.rjs"
    
    response.should have_rjs("create_account") do |rjs|
      with_tag("form[class=new_account]")
    end
    response.body.should include_text('crm.flip_form("create_account");')
  end
 
  it "cancel: should call crm.flip_form()" do
    params[:cancel] = "true"
    render "accounts/new.js.rjs"
    
    response.should_not have_rjs("create_account")
    response.body.should have_text('crm.flip_form("create_account");')
  end
 
end