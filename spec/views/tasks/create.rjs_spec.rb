require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/create.js.rjs" do
  include TasksHelper

  before(:each) do
    assigns[:current_user] = Factory(:user)
  end

  VIEWS.each do |view|
    it "create from #{view} tasks page: should hide [Create Task] form and insert task partial" do
      @task = stub_task(view)
      assigns[:view] = view
      assigns[:task] = @task
      assigns[:task_total] = stub_task_total(view)
      request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{view}"

      render "tasks/create.js.rjs"
      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      response.should include_text('visualEffect("highlight"')
    end
  end

  it "create: should show flash message when assigning a task from pending tasks view" do
    assigns[:view] = "pending"
    assigns[:task] = Factory(:task, :id => 42, :assignee => Factory(:user))
    request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render "tasks/create.js.rjs"
    
    response.should include_text('$("tasks_flash").update("The task has been created and assigned to')
    response.should include_text('$("tasks_flash").show()')
  end

  it "create: should show flash message when creating a pending task from assigned tasks view" do
    assigns[:view] = "assigned"
    assigns[:task] = Factory(:task, :id => 42, :assignee => nil)
    request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render "tasks/create.js.rjs"
    
    response.should include_text('$("tasks_flash").update("The task has been created (')
    response.should include_text('$("tasks_flash").show()')
  end

  (VIEWS - %w(assigned)).each do |view|
    it "create from outside the Tasks tab: should insert #{view} partial and highlight it" do
      @task = Factory(:task, :id => 42)
      assigns[:view] = view
      assigns[:task] = @task
      render "tasks/create.js.rjs"

      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      response.should include_text('visualEffect("highlight"')
    end
  end

  it "create failure: should re-render [create.html.haml] template in :create_task div" do
    assigns[:task] = Factory.build(:task, :name => nil) # make it invalid
  
    render "tasks/create.js.rjs"
    response.should include_text('$("create_task").visualEffect("shake"')
  end

end


