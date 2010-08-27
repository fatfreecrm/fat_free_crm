require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/new.html.erb" do
  include CommentsHelper

  before(:each) do
    assign(:comment, stub_model(Comment,
      :new_record? => true
    ))
  end

  it "should render new form" do
    render

    rendered.should match("hide()")
    rendered.should match("show()")
  end
end


