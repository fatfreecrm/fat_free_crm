require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/destroy.js.rjs" do
  include AccountsHelper

  before(:each) do
    login_and_assign
    assigns[:account] = @account = Factory(:account)
    request.env["HTTP_REFERER"] = "http://localhost/accounts"
    render "accounts/destroy.js.rjs"
  end

  it "should blind up out destroyed account partial" do
    response.should include_text(%Q/$("account_#{@account.id}").visualEffect("blind_up"/)
  end

  it "should decrement total number of accounts" do
    response.should include_text('crm.update_total(-1);')
  end

  it "should update accounts sidebar" do
    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
  end

end
