require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/edit.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
    assigns[:users] = [ @current_user ]
    assigns[:bucket] = Setting.task_bucket[1..-1] << [ "On Specific Date...", :specific_time ]
    assigns[:category] = Setting.unroll(:task_category)
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
        response.should include_text('type=\\"checkbox\\"')
      else
        response.should_not include_text('type=\\"checkbox\\"')
      end
    end

    it "edit: should hide [Create Task] form" do
      assigns[:view] = view
      assigns[:task] = stub_task(view)

      render "tasks/edit.js.rjs"
      response.should include_text('crm.hide_form("create_task"')
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

    it "edit: should remove previous [Edit Task] form if previous task is not available" do
      @previous = stub_task(view)
      assigns[:previous] = 41
      assigns[:view] = view
      assigns[:task] = stub_task(view)

      render "tasks/edit.js.rjs"
      response.should include_text(%Q/crm.flick("task_41", "remove");/)
    end

    it "edit: should turn off highlight and replace current task with [Edit Task] form" do
      @task = stub_task(view)
      assigns[:view] = view
      assigns[:task] = @task

      render "tasks/edit.js.rjs"
      response.should include_text(%Q/crm.highlight_off("task_#{@task.id}");/)
      response.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("form[class=edit_task]")
      end
      response.should include_text('$("task_name").focus()')
    end

  end

end
