require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/create.js.rjs" do
  include TasksHelper

  def stub_task_total(view = "pending")
    settings = (view == "completed" ? Setting.task_completed : Setting.task_due_at_hint)
    settings.inject({ :all => 0 }) { |hash, (value, key)| hash[key] = 1; hash }
  end

  before(:each) do
    @current_user = Factory(:user)
    @current_user.stub!(:full_name).and_return("Billy Bones")
    assigns[:current_user] = @current_user
  end

  for view in VIEWS do
    it "create from #{view} tasks page: should hide [Create Task] form and insert task partial" do
      assigns[:view] = view
      if view != "completed"
        assigns[:task] = Factory(:task, :id => 42)
      else
        assigns[:task] = Factory(:task, :id => 42, :completed_at => Time.now - 1.minute)
      end
      assigns[:task_total] = stub_task_total(view)
      request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{view}"
      render "tasks/create.js.rjs"
  
      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=task_42]")
      end
      response.should include_text('visualEffect("highlight"')
    end
  end

  it "create: should show flash message when assigning a task from pending tasks view" do
    assigns[:view] = "pending"
    assigns[:task] = Factory(:task, :id => 42, :assignee => @current_user)
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

  for view in VIEWS - %w(assigned)
    it "create from outside the Tasks tab: should insert #{view} partial and highlight it" do
      assigns[:view] = view
      assigns[:task] = Factory(:task, :id => 42)
      render "tasks/create.js.rjs"

      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=task_42]")
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


