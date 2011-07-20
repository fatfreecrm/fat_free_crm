require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/update.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  describe "Changing due date" do
    before(:each) do
      assign(:task_before_update, Factory(:task, :bucket => "due_asap"))
      assign(:task, @task       = Factory(:task, :bucket => "due_tomorrow"))
      assign(:view, "pending")
      assign(:task_total, stub_task_total("pending"))
    end

    it "from Tasks tab: should remove task from current bucket and hide empty bucket" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render

      rendered.should include(%Q/$("task_#{@task.id}").replace("")/)
      rendered.should include(%Q/$("list_due_asap").visualEffect("fade"/)
    end

    it "from Tasks tab: should show updated task in a new bucket" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render
      rendered.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      rendered.should include(%Q/$("task_#{@task.id}").visualEffect("highlight"/)
    end

    it "from Tasks tab: should update tasks sidebar" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render

      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
      rendered.should include(%Q/$("filters").visualEffect("shake"/)
    end

    it "from asset page: should update task partial in place" do
      render
      rendered.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
    end

    it "from asset page: should update recently viewed items" do
      render
      rendered.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end

  end

  describe "Reassigning" do
    before(:each) do
      assign(:task_total, stub_task_total("pending"))
    end

    it "pending task to somebody from Tasks tab: should remove the task and show flash message (assigned)" do
      assignee = Factory(:user)
      assign(:task_before_update, Factory(:task, :assignee => nil))
      assign(:task, @task       = Factory(:task, :assignee => assignee))
      assign(:view, "pending")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should include(%Q/$("task_#{@task.id}").replace("")/)
      rendered.should include('("flash").update(')
      rendered.should include('crm.flash("notice", true)')
    end

    it "assigned tasks to me from Tasks tab: should remove the task and show flash message (pending)" do
      assignee = Factory(:user)
      assign(:task_before_update, Factory(:task, :assignee => assignee))
      assign(:task, @task       = Factory(:task, :assignee => nil))
      assign(:view, "assigned")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"

      render
      rendered.should include(%Q/$("task_#{@task.id}").replace("")/)
      rendered.should include('("flash").update(')
      rendered.should include('crm.flash("notice", true)')
    end

    it "assigned tasks to somebody else from Tasks tab: should re-render task partial" do
      assign(:task_before_update, Factory(:task, :assignee => Factory(:user)))
      assign(:task, @task       = Factory(:task, :assignee => Factory(:user)))
      assign(:view, "assigned")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"

      render
      rendered.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
    end

    it "from Tasks tab: should update tasks sidebar" do
      assign(:task_before_update, Factory(:task, :assignee => nil))
      assign(:task, @task       = Factory(:task, :assignee => Factory(:user)))
      assign(:view, "assigned")
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks?view=assigned"
      render

      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
      rendered.should include(%Q/$("filters").visualEffect("shake"/)
    end

    it "from asset page: should should re-render task partial" do
      assign(:task_before_update, Factory(:task, :assignee => nil))
      assign(:task, @task       = Factory(:task, :assignee => Factory(:user)))
      render

      rendered.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
    end

    it "from asset page: should update recently viewed items" do
      assign(:task_before_update, Factory(:task, :assignee => nil))
      assign(:task, @task       = Factory(:task, :assignee => Factory(:user)))
      render

      rendered.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end

  end

  it "error: should re-disiplay [Edit Task] form and shake it" do
    assign(:task_before_update, Factory(:task))
    assign(:task, @task = Factory(:task))
    @task.errors.add(:name)

    render
    rendered.should include(%/$("task_#{@task.id}").visualEffect("shake"/)
    rendered.should include(%/$("task_submit").enable()/)
  end

end
