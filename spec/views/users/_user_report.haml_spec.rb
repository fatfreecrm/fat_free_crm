require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/_user_report.html.erb" do
  include UsersHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render a list of assigned opportunities if it's not empty" do
    user = Factory(:user)
    Factory(:opportunity, :assignee => user)
    template.should_receive(:render).with(hash_including(:partial => "opportunity"))
    render "/users/_user_report.html.haml", :locals => {:user_report => user}
  end

end

