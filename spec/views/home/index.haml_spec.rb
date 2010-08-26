require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/index.html.haml" do
  include HomeHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render list of activities if it's not empty" do
    assigns[:activities] = [ Factory(:activity, :action => "updated", :subject => Factory(:account)) ]
    view.should_receive(:render).with(hash_including(:partial => "activity"))
    render
  end

  it "should render a message if there're no activities" do
    assigns[:activities] = []
    view.should_not_receive(:render).with(hash_including(:partial => "activity"))

    render
    rendered.body.should include("No activity records found.")
  end
end

