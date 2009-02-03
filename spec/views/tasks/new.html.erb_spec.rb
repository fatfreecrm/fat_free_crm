require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/new.html.erb" do
  include TasksHelper
  
  before(:each) do
    assigns[:task] = stub_model(Task,
      :uuid => "12345678-0123-5678-0123-567890123456",
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/tasks/new.js.rjs"
    
    response.should include_text("Effect.toggle") do
    end
  end
end


