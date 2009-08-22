require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/authentications/new.html.haml" do
  include AuthenticationsHelper

  before(:each) do
    activate_authlogic
    assigns[:authentication] = @authentication = Authentication.new
  end

  it "renders the login form without signup link" do
    template.should_receive(:can_signup?).and_return(false)
    render
    response.should have_tag("form[action=#{authentication_path}][class=new_authentication]")
    response.should_not have_tag("a[href=#{signup_path}]")
  end

  it "renders the login form with signup link" do
    template.should_receive(:can_signup?).and_return(true)
    render
    response.should have_tag("form[action=#{authentication_path}][class=new_authentication]")
    response.should have_tag("a[href=#{signup_path}]")
  end
end
