require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/emails/index.html.haml" do
  include EmailsHelper
  
  before do
    email_98 = mock_model(Email)
    email_99 = mock_model(Email)

    assigns[:emails] = [email_98, email_99]
  end

  it "should render list of emails" do
    render "/emails/index.html.haml"
  end
end
