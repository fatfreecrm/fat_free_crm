require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/index.html.erb" do
  include CommentsHelper
  
  before(:each) do
    assigns[:comments] = [
      stub_model(Comment),
      stub_model(Comment)
    ]
  end

  it "should render list of comments" do
    render "/comments/index.html.erb"
  end
end

