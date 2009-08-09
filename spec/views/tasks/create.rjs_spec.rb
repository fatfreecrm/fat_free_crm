require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/create.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  (VIEWS - %w(completed)).each do |view|
    describe "create from #{view} tasks page" do
      before(:each) do
        assigns[:view] = view
        assigns[:task] = @task = stub_task(view)
        assigns[:task_total] = stub_task_total(view)
        request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{view}"
        render
      end

      it "should hide [Create Task] form and insert task partial" do
        response.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=task_#{@task.id}]")
        end
        response.should include_text(%Q/$("task_#{@task.id}").visualEffect("highlight"/)
      end

      it "should update tasks title" do
        if view == "assigned"
          response.should include_text('$("title").update("Assigned Tasks")')
        else
          response.should include_text('$("title").update("Tasks")')
        end
      end

      it "should update tasks sidebar" do
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        response.should include_text(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end

  it "should show flash message when assigning a task from pending tasks view" do
    assigns[:view] = "pending"
    assigns[:task] = Factory(:task, :id => 42, :assignee => Factory(:user))
    request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render
    
    response.should include_text('$("flash").update(')
    response.should include_text('crm.flash("notice", true)')
  end

  it "should update recent items when assigning a task from pending tasks view" do
    assigns[:view] = "pending"
    assigns[:task] = Factory(:task, :id => 42, :assignee => Factory(:user))
    request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    response.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]", :text => "Recent Items")
    end
  end

  it "should show flash message when creating a pending task from assigned tasks view" do
    assigns[:view] = "assigned"
    assigns[:task] = Factory(:task, :id => 42, :assignee => nil)
    request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render
    
    response.should include_text('$("flash").update(')
    response.should include_text('crm.flash("notice", true)')
  end

  it "should update recent items when creating a pending task from assigned tasks view" do
    assigns[:view] = "assigned"
    assigns[:task] = Factory(:task, :id => 42, :assignee => nil)
    request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

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
        render
      end

      it "should update tasks title" do
        response.should include_text('$("create_task_title").update("Tasks")')
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
    render

    response.should include_text('$("create_task").visualEffect("shake"')
  end

end


