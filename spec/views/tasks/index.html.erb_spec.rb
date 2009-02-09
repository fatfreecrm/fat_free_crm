require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/index.html.erb" do
  include TasksHelper
  
  before(:each) do
    assigns[:task] = mock_model(Task,
      :name => "Lorem ipsum",
      :user => mock_model(User),
      :category => nil,
      :due_at_hint => nil,
      :due_at => nil,
      :calendar => nil
    )
    assigns[:tasks] = { :key => [ stub_model(Task), stub_model(Task) ] }
    assigns[:current_user] = mock_model(User)
    assigns[:due_at_hint] = assigns[:category] = [[ :key, "value" ]]
    Setting.stub!(:task_category_color).and_return({ :key => "value" })
    Setting.stub!(:task_due_at_hint).and_return({ :key => "value" })
  end

  it "should render list of tasks" do
    render "/tasks/index_pending.html.haml"
  end
end

