require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/show.html.erb" do
  include CommentsHelper
  before(:each) do
    assigns[:comment] = @comment = stub_model(Comment)
  end

  it "should render attributes in <p>" do
    render "/comments/show.html.erb"
  end
end

