require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/show.html.haml" do
  include CommentsHelper
  before(:each) do
    assign(:comment, @comment = stub_model(Comment))
  end

  it "should render attributes in <p>" do
    render
  end
end
