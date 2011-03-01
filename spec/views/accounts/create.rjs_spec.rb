require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/create.js.rjs" do
  include AccountsHelper

  before do
    login_and_assign
  end

  # Note: [Create Account] is only called from Accounts index. Unlike other
  # core object Account partial is not embedded.
  describe "create success" do
    before do
      assign(:account, @account = Factory(:account))
      assign(:accounts, [ @account ].paginate)
      assign(:account_category_total, Hash.new(1))
      render
    end

    it "should hide [Create Account] form and insert account partial" do
      rendered.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=account_#{@account.id}]")
      end
      rendered.should include(%Q/$("account_#{@account.id}").visualEffect("highlight"/)
    end

    it "should update pagination" do
      rendered.should have_rjs("paginate")
    end

    it "should refresh accounts sidebar" do
      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_account div" do
      assign(:account, Factory.build(:account, :name => nil)) # make it invalid
      assign(:users, [ @current_user ])
      render

      rendered.should have_rjs("create_account") do |rjs|
        with_tag("form[class=new_account]")
      end
      rendered.should include('$("create_account").visualEffect("shake"')
    end
  end

end


