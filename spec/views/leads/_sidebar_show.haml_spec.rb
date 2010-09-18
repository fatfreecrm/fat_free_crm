require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_sidebar_show.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
    assign(:lead, Factory(:lead,
                          :blog => 'http://www.blogger.com/home',
                          :linkedin => 'www.linkedin.com',
                          :twitter => 'twitter.com/account',
                          :facebook => ''))
  end

  it "should render working web presence links whether a protocol is provided or not" do
    render
    rendered.should have_tag("a[href=http://www.blogger.com/home]")
    rendered.should have_tag("a[href=http://www.linkedin.com]")
    rendered.should have_tag("a[href=http://twitter.com/account]")
    rendered.should_not have_tag("a[href=http://www.facebook/profile]")
  end
end
