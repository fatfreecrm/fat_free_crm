require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index.js.rjs" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render [account] template with @accounts collection if there are accounts" do
    assign(:accounts, [ Factory(:account, :id => 42) ].paginate)

    render
    rendered.should have_rjs("accounts") do |rjs|
      with_tag("li[id=account_#{42}]")
    end
    rendered.should have_rjs("paginate")
  end

  it "should render [empty] template if @accounts collection if there are no accounts" do
    assign(:accounts, [].paginate)

    render
    rendered.should have_rjs("accounts") do |rjs|
      with_tag("div[id=empty]")
    end
    rendered.should have_rjs("paginate")
  end

end