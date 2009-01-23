require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/new.html.erb" do
  include TasksHelper
  
  before(:each) do
    assigns[:task] = stub_model(Task,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/tasks/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", tasks_path) do
    end
  end
end


