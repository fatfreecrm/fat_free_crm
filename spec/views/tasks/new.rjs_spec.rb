require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/new.html.haml" do
  include TasksHelper

  before(:each) do
    login_and_assign
    assigns[:task] = Factory.build(:task)
    assigns[:users] = [ @current_user ]
    assigns[:bucket] = Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ]
    assigns[:category] = Setting.unroll(:task_category)
  end

  it "should toggle empty message div if it exists" do
    render "tasks/new.js.rjs"

    response.should include_text('crm.flick("empty", "toggle")')
  end

  describe "new task" do
    it "create: should render [new.html.haml] template into :create_task div" do
      params[:cancel] = nil
      render "tasks/new.js.rjs"
    
      response.should have_rjs("create_task") do |rjs|
        with_tag("form[class=new_task]")
      end
      response.should include_text('crm.flip_form("create_task");')
    end

    it "should call JavaScript functions to load Calendar popup" do
      params[:cancel] = nil
      render "tasks/new.js.rjs"

      response.should include_text('crm.date_select_popup("task_calendar", "task_bucket")')
    end
  end

  describe "cancel new task" do
    it "should hide [create task] form" do
      params[:cancel] = "true"
      render "tasks/new.js.rjs"

      response.should_not have_rjs("create_task")
      response.should include_text('crm.flip_form("create_task");')
    end
  end

end
