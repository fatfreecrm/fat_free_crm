require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/emails/show.html.haml" do
  include EmailsHelper
  
  before do
    @email = mock_model(Email)

    assigns[:email] = @email
  end

  it "should render attributes in <p>" do
    render "/emails/show.html.haml"
  end
end

