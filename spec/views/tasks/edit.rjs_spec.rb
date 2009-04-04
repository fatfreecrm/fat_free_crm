require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/edit.js.rjs" do
  include TasksHelper

  before(:each) do
    @current_user = Factory(:user)
    assigns[:current_user] = @current_user
    assigns[:users] = [ @current_user ]
    assigns[:due_at_hint] = Setting.task_due_at_hint[1..-1] << [ "On Specific Date...", :specific_time ]
    assigns[:category] = Setting.invert(:task_category)
  end


  %w(pending assigned).each do |view|
    it "cancel for #{view} view: should replace [Edit Task] form with the task partial" do
      params[:cancel] = "true"
      @task = stub_task(view)
      assigns[:view] = view
      assigns[:task] = @task
    
      render "tasks/edit.js.rjs"
      response.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      if view == "pending"
        response.body.should include_text('type=\\"checkbox\\"')
      else
        response.body.should_not include_text('type=\\"checkbox\\"')
      end
    end

    it "edit: should hide [Create Task] form" do
      assigns[:view] = view
      assigns[:task] = stub_task(view)

      render "tasks/edit.js.rjs"
      response.body.should include_text('crm.hide_form("create_task"')
    end

    it "edit: should hide previously open [Edit Task] form" do
      @previous = stub_task(view)
      assigns[:previous] = @previous
      assigns[:view] = view
      assigns[:task] = stub_task(view)
      
      render "tasks/edit.js.rjs"
      response.should have_rjs("task_#{@previous.id}") do |rjs|
        with_tag("li[id=task_#{@previous.id}]")
      end
    end

    it "edit: should turn off highlight and replace current task with [Edit Task] form" do
      @task = stub_task(view)
      assigns[:view] = view
      assigns[:task] = @task

      render "tasks/edit.js.rjs"
      response.body.should include_text(%Q/crm.highlight_off("task_#{@task.id}");/)
      response.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("form[class=edit_task]")
      end
      response.body.should include_text('$("task_name").focus()')
    end

  end

end
