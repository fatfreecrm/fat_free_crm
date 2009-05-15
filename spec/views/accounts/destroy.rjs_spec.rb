require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/destroy.js.rjs" do
  include AccountsHelper

  before(:each) do
    login_and_assign
    assigns[:account] = @account = Factory(:account)
    assigns[:accounts] = [ @account ].paginate
    render "accounts/destroy.js.rjs"
  end

  it "should blind up destroyed account partial" do
    response.should include_text(%Q/$("account_#{@account.id}").visualEffect("blind_up"/)
  end

  it "should update accounts pagination" do
    response.should have_rjs("paginate")
  end

  it "should update accounts sidebar" do
    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
      with_tag("div[id=recently]")
    end
  end

end
