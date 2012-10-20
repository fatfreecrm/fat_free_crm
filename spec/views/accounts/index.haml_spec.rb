require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index" do
  include AccountsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Account.per_page
    assign :sort_by,  Account.sort_by
    view.stub(:search) { Account.search {} }
    login_and_assign
  end

  it "should render a proper account website link if an account is provided" do
    assign(:accounts, [ FactoryGirl.create(:account, :website => 'www.fatfreecrm.com'), FactoryGirl.create(:account) ].paginate)
    render
    rendered.should have_tag("a[href=http://www.fatfreecrm.com]")
  end

  it "should render list of accounts if list of accounts is not empty" do
    assign(:accounts, [ FactoryGirl.create(:account), FactoryGirl.create(:account) ].paginate)

    render
    view.should render_template(:partial => "_account")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no accounts" do
    assign(:accounts, [].paginate)

    render
    view.should_not render_template(:partial => "_account")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end
end

