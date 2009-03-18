require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index.html.erb" do
  include LeadsHelper
  
  before(:each) do
  end

  it "should render list of accounts if list of leads is not empty" do
    assigns[:leads] = [ Factory(:lead) ]
    template.should_receive(:render).with(hash_including(:partial => "lead"))
    render "/leads/index.html.haml"
  end

end

