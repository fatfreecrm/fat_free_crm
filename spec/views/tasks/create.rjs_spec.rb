require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/create.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  (TASK_STATUSES - %w(completed)).each do |status|
    describe "create from #{status} tasks page" do
      before(:each) do
        assign(:view, status)
        assign(:task, @task = stub_task(status))
        assign(:task_total, stub_task_total(status))
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=#{status}"
        render
      end

      it "should hide [Create Task] form and insert task partial" do
        rendered.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=task_#{@task.id}]")
        end
        rendered.should include(%Q/$("task_#{@task.id}").visualEffect("highlight"/)
      end

      it "should update tasks title" do
        if status == "assigned"
          rendered.should include('$("title").update("Assigned Tasks")')
        else
          rendered.should include('$("title").update("Tasks")')
        end
      end

      it "should update tasks sidebar" do
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        rendered.should include(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end

  it "should show flash message when assigning a task from pending tasks view" do
    assign(:view, "pending")
    assign(:task, Factory(:task, :id => 42, :assignee => Factory(:user)))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    rendered.should include('$("flash").update(')
    rendered.should include('crm.flash("notice", true)')
  end

  it "should update recent items when assigning a task from pending tasks view" do
    assign(:view, "pending")
    assign(:task, Factory(:task, :id => 42, :assignee => Factory(:user)))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
    render

    rendered.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]", :text => "Recent Items")
    end
  end

  it "should show flash message when creating a pending task from assigned tasks view" do
    assign(:view, "assigned")
    assign(:task, Factory(:task, :id => 42, :assignee => nil))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

    rendered.should include('$("flash").update(')
    rendered.should include('crm.flash("notice", true)')
  end

  it "should update recent items when creating a pending task from assigned tasks view" do
    assign(:view, "assigned")
    assign(:task, Factory(:task, :id => 42, :assignee => nil))
    controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
    render

    rendered.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]", :text => "Recent Items")
    end
  end

  (TASK_STATUSES - %w(assigned)).each do |status|
    describe "create from outside the Tasks tab" do
      before(:each) do
        @task = Factory(:task, :id => 42)
        assign(:view, status)
        assign(:task, @task)
        render
      end

      it "should update tasks title" do
        rendered.should include('$("create_task_title").update("Tasks")')
      end

      it "should insert #{status} partial and highlight it" do
        rendered.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=task_#{@task.id}]")
        end
        rendered.should include(%Q/$("task_#{@task.id}").visualEffect("highlight"/)
      end

      it "should update recently viewed items" do
        rendered.should have_rjs("recently") do |rjs|
          with_tag("div[class=caption]", :text => "Recent Items")
        end
      end
    end
  end

  it "create failure: should re-render [create.html.haml] template in :create_task div" do
    assign(:task, Factory.build(:task, :name => nil)) # make it invalid
    render

    rendered.should include('$("create_task").visualEffect("shake"')
    rendered.should include(%/$("task_submit").enable()/)
  end

end
