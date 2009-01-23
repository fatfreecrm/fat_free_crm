require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/index.html.erb" do
  include TasksHelper
  
  before(:each) do
    assigns[:tasks] = [
      stub_model(Task),
      stub_model(Task)
    ]
  end

  it "should render list of tasks" do
    render "/tasks/index.html.erb"
  end
end

