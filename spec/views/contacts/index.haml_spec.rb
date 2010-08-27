require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index.html.erb" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render a list of contacts if it's not empty" do
    assign(:contacts, [ Factory(:contact) ].paginate)
    view.should render_template(:partial => "_contact")
    view.should render_template(:partial => "common/_paginate")
    render
  end

  it "should render a message if there're no contacts" do
    assign(:contacts, [].paginate)
    view.should_not render_template(:partial => "_contact")
    view.should render_template(:partial => "common/_empty")
    view.should render_template(:partial => "common/_paginate")
    render
  end

end

