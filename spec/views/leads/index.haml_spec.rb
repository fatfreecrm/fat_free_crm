require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
  end

  it "should render list of accounts if list of leads is not empty" do
    assign(:leads, [ Factory(:lead) ].paginate(:page => 1, :per_page => 20))

    render
    view.should render_template(:partial => "_lead")
    view.should render_template(:partial => "common/_paginate")
  end

  it "should render a message if there're no leads" do
    assign(:leads, [].paginate(:page => 1, :per_page => 20))

    render
    view.should_not render_template(:partial => "_leads")
    view.should render_template(:partial => "common/_empty")
    view.should render_template(:partial => "common/_paginate")
  end

end
