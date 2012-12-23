require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/new" do
  include TasksHelper

  before do
    login_and_assign
    assign(:task, FactoryGirl.build(:task))
    assign(:users, [ current_user ])
    assign(:bucket, Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ])
    assign(:category, Setting.unroll(:task_category))
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  describe "new task" do
    before { @task_with_time = Setting.task_calendar_with_time }
    after  { Setting.task_calendar_with_time = @task_with_time }

    it "create: should render [new] template into :create_task div" do
      params[:cancel] = nil
      render

      rendered.should have_rjs("create_task") do |rjs|
        with_tag("form[class=new_task]")
      end
      rendered.should include('crm.flip_form("create_task");')
    end
  end

  describe "cancel new task" do
    it "should hide [create task] form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("create_task")
      rendered.should include('crm.flip_form("create_task");')
    end
  end

end
