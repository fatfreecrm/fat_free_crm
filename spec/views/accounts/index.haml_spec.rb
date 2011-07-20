require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index.html.haml" do
  include AccountsHelper

  before(:each) do
    login_and_assign
  end

  it "should render a proper account website link if an account is provided" do
    assign(:accounts, [ Factory(:account, :website => 'www.fatfreecrm.com'), Factory(:account) ].paginate)
    render
    rendered.should have_tag("a[href=http://www.fatfreecrm.com]")
  end

  it "should render list of accounts if list of accounts is not empty" do
    assign(:accounts, [ Factory(:account), Factory(:account) ].paginate)

    render
    view.should render_template(:partial => "_account")
    view.should render_template(:partial => "common/_paginate")
  end

  it "should render a message if there're no accounts" do
    assign(:accounts, [].paginate)

    render
    view.should_not render_template(:partial => "_account")
    view.should render_template(:partial => "common/_empty")
    view.should render_template(:partial => "common/_paginate")
  end
end
