require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/email/edit.html.haml" do
  include EmailsHelper
  
  before do
    @email = mock_model(Email)
    assigns[:email] = @email
  end

  it "should render edit form" do
    render "/emails/edit.html.haml"
    
    response.should have_tag("form[action=#{email_path(@email)}][method=post]") do
    end
  end
end