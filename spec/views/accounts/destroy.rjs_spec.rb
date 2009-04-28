require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/destroy.js.rjs" do
  include AccountsHelper

  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:account] = @account
    request.env["HTTP_REFERER"] = "http://localhost/accounts"
  end

  it "should blind up out destroyed account partial" do
    render "accounts/destroy.js.rjs"

    response.should include_text(%Q/$("account_#{@account.id}").visualEffect("BlindUp"/)
  end

  it "should decrement total number of accounts" do
    render "accounts/destroy.js.rjs"

    response.should include_text('crm.update_total(-1);')
  end

  it "should update accounts sidebar" do
    render "accounts/destroy.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
  end
end
