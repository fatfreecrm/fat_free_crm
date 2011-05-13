require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.haml" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    assigns[:users] = [ @current_user ]
    assigns[:comment] = Comment.new
    assigns[:lead] = Factory(:lead, 
                             :blog => 'http://www.blogger.com/home',
                             :linkedin => 'www.linkedin.com',
                             :twitter => 'twitter.com/account',
                             :facebook => '')
  end
  
  it "should render working web presence links whether a protocol is provided or not" do
    render "leads/_sidebar_show.html.haml"
    response.should have_tag("a[href=http://www.blogger.com/home]")
    response.should have_tag("a[href=http://www.linkedin.com]")
    response.should have_tag("a[href=http://twitter.com/account]")
    response.should_not have_tag("a[href=http://www.facebook/profile]")
  end
  
  it "should display unassigned, if assigned_to is nil" do
    assigns[:lead].update_attributes(:assigned_to => nil)
    render "leads/_sidebar_show.html.haml"
    response.should include_text(t(:unassigned))
  end
  it "should display full_name of assignee, if lead has been assigned to someone" do
    assigns[:lead].update_attributes(:assigned_to => @current_user.id)
    render "leads/_sidebar_show.html.haml"
    response.should include_text(@current_user.full_name)
  end
  
end
