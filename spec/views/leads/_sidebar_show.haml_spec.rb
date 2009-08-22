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
end
