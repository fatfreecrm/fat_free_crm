require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index.html.haml" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render list of accounts if list of leads is not empty" do
    assigns[:leads] = [ Factory(:lead) ].paginate(:page => 1, :per_page => 20)
    view.should_receive(:render).with(hash_including(:partial => "lead"))
    view.should_receive(:render).with(:partial => "common/paginate")
    render "/leads/index.html.haml"
  end

  it "should render a message if there're no leads" do
    assigns[:leads] = [].paginate(:page => 1, :per_page => 20)
    view.should_not_receive(:render).with(hash_including(:partial => "leads"))
    view.should_receive(:render).with(:partial => "common/empty")
    view.should_receive(:render).with(:partial => "common/paginate")
    render "/leads/index.html.haml"
  end

end

