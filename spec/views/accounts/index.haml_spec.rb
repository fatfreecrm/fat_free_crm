require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index.html.haml" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render list of accounts if list of accounts is not empty" do
    assigns[:accounts] = [ Factory(:account) ]
    template.should_receive(:render).with(hash_including(:partial => "account"))
    render "/accounts/index.html.haml"
  end

  it "should render a message if there're no accounts" do
    assigns[:accounts] = []
    template.should_not_receive(:render).with(hash_including(:partial => "account"))
    render "/accounts/index.html.haml"
  end
end

