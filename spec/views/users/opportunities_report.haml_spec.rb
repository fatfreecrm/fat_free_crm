require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/opportunities_report.html.erb" do
  include UsersHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render a list of users if it's not empty" do
    assigns[:users] = [ Factory(:user) ]
    template.should_receive(:render).with(hash_including(:partial => "user_report"))
    render "/users/opportunities_report.html.haml"
  end

  it "should render a message if there are no users with assigned opportunities" do
    assigns[:users] = []
    template.should_not_receive(:render).with(hash_including(:partial => "user_report"))
    render "/users/opportunities_report.html.haml"
    response.should include_text(t(:no_users_found_with_assigned_opportunities))
  end

end

