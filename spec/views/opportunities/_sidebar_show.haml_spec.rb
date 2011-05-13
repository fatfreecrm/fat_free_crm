require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show.html.haml" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assigns[:users] = [ @current_user ]
    assigns[:opportunity] = Factory(:opportunity)
  end

  it "should display unassigned, if assigned_to is nil" do
    assigns[:opportunity].update_attributes(:assigned_to => nil)
    render "opportunities/_sidebar_show.html.haml"
    response.should include_text(t(:unassigned))
  end
  it "should display full_name of assignee, if lead has been assigned to someone" do
    assigns[:opportunity].update_attributes(:assigned_to => @current_user.id)
    render "opportunities/_sidebar_show.html.haml"
    response.should include_text(@current_user.full_name)
  end
  
end