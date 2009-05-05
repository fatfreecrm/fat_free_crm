require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index.html.erb" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render a list of contacts if it's not empty" do
    assigns[:contacts] = [ Factory(:contact) ].paginate
    template.should_receive(:render).with(hash_including(:partial => "contact"))
    template.should_receive(:render).with(:partial => "common/paginate")
    render "/contacts/index.html.haml"
  end

  it "should render a message if there're no contacts" do
    assigns[:contacts] = [].paginate
    template.should_not_receive(:render).with(hash_including(:partial => "contact"))
    template.should_receive(:render).with(:partial => "common/empty")
    template.should_receive(:render).with(:partial => "common/paginate")
    render "/contacts/index.html.haml"
  end

end

