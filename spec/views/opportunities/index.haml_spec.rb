require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assigns[:opportunities] = [ Factory(:opportunity) ]
    template.should_receive(:render).with(hash_including(:partial => "opportunity"))
    render "/opportunities/index.html.haml"
  end

end

