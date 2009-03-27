require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/new.js.rjs" do
  include ContactsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @account = Factory(:account)
    assigns[:contact] = Contact.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end
 
  it "create: should render [new.html.haml] template into :create_contact div" do
    params[:cancel] = nil
    render "contacts/new.js.rjs"
    
    response.should have_rjs("create_contact") do |rjs|
      with_tag("form[class=new_contact]")
    end
  end

end


