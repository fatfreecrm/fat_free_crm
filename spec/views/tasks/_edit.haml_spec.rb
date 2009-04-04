require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/edit.html.erb" do
  include TasksHelper
  
  before(:each) do
    @current_user = Factory(:user)
    assigns[:task] = Factory(:task, :asset => Factory(:account), :bucket => "due_asap")
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:bucket] = %w(due_asap due_today)
    assigns[:category] = %w(meeting money)
  end

  it "should render [edit task] form" do
    template.should_receive(:render).with(hash_including(:partial => "tasks/top_section"))
    render "/tasks/_edit.html.haml"

    response.should have_tag("form[class=edit_task]")
  end

end


