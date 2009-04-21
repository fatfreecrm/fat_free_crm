require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/create.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  VIEWS.each do |view|
    before(:each) do
      @task = stub_task(view)
      assigns[:view] = view
      assigns[:task] = @task
      assigns[:task_total] = stub_task_total(view)
    end

    describe "create from #{view} tasks page" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{view}"
        render "tasks/create.js.rjs"
      end

      it "should hide [Create Task] form and insert task partial" do
        response.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=task_#{@task.id}]")
        end
        response.should include_text(%Q/$("task_#{@task.id}").visualEffect("highlight"/)
      end

      it "should update tasks sidebar" do
        response.body.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        response.body.should include_text(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end

  it "should show flash message when assigning a task from pending tasks view" do
    assigns[:view] = "pending"
    assigns[:task] = Factory(:task, :id => 42, :assignee => Factory(:user))
    request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render "tasks/create.js.rjs"
    
    response.should include_text('$("tasks_flash").update("The task has been created and assigned to')
    response.should include_text('$("tasks_flash").show()')
  end

  it "should update recent items when assigning a task from pending tasks view" do
    assigns[:view] = "pending"
    assigns[:task] = Factory(:task, :id => 42, :assignee => Factory(:user))
    request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render "tasks/create.js.rjs"

    response.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]", :text => "Recent Items")
    end
  end

  it "should show flash message when creating a pending task from assigned tasks view" do
    assigns[:view] = "assigned"
    assigns[:task] = Factory(:task, :id => 42, :assignee => nil)
    request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render "tasks/create.js.rjs"
    
    response.should include_text('$("tasks_flash").update("The task has been created (')
    response.should include_text('$("tasks_flash").show()')
  end

  it "should update recent items when creating a pending task from assigned tasks view" do
    assigns[:view] = "assigned"
    assigns[:task] = Factory(:task, :id => 42, :assignee => nil)
    request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render "tasks/create.js.rjs"

    response.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]", :text => "Recent Items")
    end
  end

  (VIEWS - %w(assigned)).each do |view|
    describe "create from outside the Tasks tab" do
      before(:each) do
        @task = Factory(:task, :id => 42)
        assigns[:view] = view
        assigns[:task] = @task
        render "tasks/create.js.rjs"
      end

      it "should insert #{view} partial and highlight it" do
        response.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=task_#{@task.id}]")
        end
        response.should include_text(%Q/$("task_#{@task.id}").visualEffect("highlight"/)
      end

      it "should update recently viewed items" do
        response.should have_rjs("recently") do |rjs|
          with_tag("div[class=caption]", :text => "Recent Items")
        end
      end
    end
  end

  it "create failure: should re-render [create.html.haml] template in :create_task div" do
    assigns[:task] = Factory.build(:task, :name => nil) # make it invalid
    render "tasks/create.js.rjs"

    response.should include_text('$("create_task").visualEffect("shake"')
  end

end


