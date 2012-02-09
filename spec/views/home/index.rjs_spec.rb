require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/index" do
  include HomeHelper

  before do
    login_and_assign
  end

  it "should render [activity] template with @activities collection" do
    assign(:activities, [ Factory(:activity, :id => 42, :action => "updated", :subject => Factory(:account)) ])

    render :template => 'home/index', :formats => [:js]
    
    rendered.should have_rjs("activities") do |rjs|
      with_tag("li[id=activity_42]")
    end
  end

  it "should render a message if there're no activities" do
    assign(:activities, [])

    render :template => 'home/index', :formats => [:js]
    
    rendered.should have_rjs("activities")
    rendered.should include("No activity records found.")
  end

end

