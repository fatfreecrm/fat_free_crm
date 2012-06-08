require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/index" do
  include HomeHelper

  before do
    login_and_assign
  end

  it "should render list of activities if it's not empty" do
    assign(:activities, [ FactoryGirl.create(:version, :event => "update", :item => FactoryGirl.create(:account)) ])
    assign(:my_tasks, [])
    assign(:my_opportunities, [])
    assign(:my_accounts, [])
    render
    view.should render_template(:partial => "_activity")
  end

  it "should render a message if there're no activities" do
    assign(:activities, [])
    assign(:my_tasks, [])
    assign(:my_opportunities, [])
    assign(:my_accounts, [])
    render
    view.should_not render_template(:partial => "_activity")

    rendered.should include("No activity records found.")
  end
end

