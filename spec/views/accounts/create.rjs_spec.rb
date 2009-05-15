require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/create.js.rjs" do
  include AccountsHelper

  before(:each) do
    login_and_assign
  end

  # Note: [Create Account] is only called from Accounts index. Unlike other
  # core object Account partial is not embedded.
  describe "create success" do
    before(:each) do
      assigns[:account] = @account = Factory(:account)
      assigns[:accounts] = [ @account ].paginate
      render "accounts/create.js.rjs"
    end

    it "should hide [Create Account] form and insert account partial" do
      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=account_#{@account.id}]")
      end
      response.should include_text(%Q/$("account_#{@account.id}").visualEffect("highlight"/)
    end

    it "should update pagination" do
      response.should have_rjs("paginate")
    end

    it "should refresh accounts sidebar" do
      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_account div" do
      assigns[:account] = Factory.build(:account, :name => nil) # make it invalid
      assigns[:users] = [ @current_user ]
      render "accounts/create.js.rjs"

      response.should have_rjs("create_account") do |rjs|
        with_tag("form[class=new_account]")
      end
      response.should include_text('$("create_account").visualEffect("shake"')
    end
  end

end


