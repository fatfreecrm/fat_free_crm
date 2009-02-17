require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/new.html.erb" do
  include CommentsHelper
  
  before(:each) do
    assigns[:comment] = stub_model(Comment,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/comments/new.js.rjs"
    
    response.should include_text("hide()")
    response.should include_text("show()")
  end
end


