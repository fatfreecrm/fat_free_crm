require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/create.js.rjs" do
  include AccountsHelper

  before(:each) do
    login_and_assign
  end

  it "create (success): should hide [Create Account] form and insert account partial" do
    assigns[:account] = Factory(:account, :id => 42)
    render "accounts/create.js.rjs"

    response.should have_rjs(:insert, :top) do |rjs|
      with_tag("li[id=account_42]")
    end
    response.should include_text('$("account_42").visualEffect("highlight"')
  end

  it "create (success): should increment total number of accounts" do
    assigns[:account] = Factory(:account, :id => 42)
    render "accounts/create.js.rjs"

    response.should include_text('crm.update_total(1);')
  end

  it "create (success): should refresh sidebar" do
    assigns[:account] = Factory(:account, :id => 42)
    render "accounts/create.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
  end
 
  it "create (failure): should re-render [create.html.haml] template in :create_account div" do
    assigns[:account] = Factory.build(:account, :name => nil) # make it invalid
    assigns[:users] = [ @current_user ]
    render "accounts/create.js.rjs"

    response.should have_rjs("create_account") do |rjs|
      with_tag("form[class=new_account]")
    end
    response.should include_text('$("create_account").visualEffect("shake"')
  end

end


