require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/emails/new.html.haml" do
  include EmailsHelper
  
  before do
    @email = mock_model(Email)
    @email.stub!(:new_record?).and_return(true)
    assigns[:email] = @email
  end

  it "should render new form" do
    render "/emails/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", emails_path) do
    end
  end
end
