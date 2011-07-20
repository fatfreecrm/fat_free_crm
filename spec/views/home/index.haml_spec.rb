require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/index.html.haml" do
  include HomeHelper

  before(:each) do
    login_and_assign
  end

  it "should render list of activities if it's not empty" do
    assign(:activities, [ Factory(:activity, :action => "updated", :subject => Factory(:account)) ])

    render
    view.should render_template(:partial => "_activity")
  end

  it "should render a message if there're no activities" do
    assign(:activities, [])

    render
    view.should_not render_template(:partial => "_activity")

    rendered.should include("No activity records found.")
  end
end
