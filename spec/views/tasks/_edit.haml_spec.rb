require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/_edit.html.haml" do
  include TasksHelper

  before(:each) do
    login_and_assign
    assign(:task, Factory(:task, :asset => Factory(:account), :bucket => "due_asap"))
    assign(:users, [ @current_user ])
    assign(:bucket, %w(due_asap due_today))
    assign(:category, %w(meeting money))
  end

  it "should render [edit task] form" do
    render

    view.should render_template(:partial => "tasks/_top_section")

    rendered.should have_tag("form[class=edit_task]")
  end

  [ "As Soon As Possible", "Today", "Tomorrow", "This Week", "Next Week", "Sometime Later" ].each do |day|
    it "should render move to [#{day}] link" do
      render

      rendered.should have_tag("a[onclick^=crm.reschedule]", :text => day)
    end
  end

  it "should render background info if Settings request so" do
    Setting.background_info = [ :task ]
    render

    rendered.should have_tag("textarea[id=task_background_info]")
  end

  it "should not render background info if Settings do not request so" do
    Setting.background_info = []
    render

    rendered.should_not have_tag("textarea[id=task_background_info]")
  end
end


