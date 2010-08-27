require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index.html.erb" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render a list of contacts if it's not empty" do
    assign(:contacts, [ Factory(:contact) ].paginate)
    view.should_receive(:render).with(hash_including(:partial => "contact"))
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

  it "should render a message if there're no contacts" do
    assign(:contacts, [].paginate)
    view.should_not_receive(:render).with(hash_including(:partial => "contact"))
    view.should_receive(:render).with(:partial => "common/empty")
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

end

