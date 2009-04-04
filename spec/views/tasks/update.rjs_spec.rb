require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/update.js.rjs" do
  include TasksHelper
  
  describe "Changing task due date" do
    before(:each) do
      assigns[:old_bucket] = "due_asap"
      assigns[:new_bucket] = "due_tomorrow"
      @task = Factory(:task, :bucket => "due_tomorrow", :user => Factory(:user))
      assigns[:task] = @task
      assigns[:view] = "pending"
      assigns[:current_user] = Factory(:user)
      assigns[:task_total] = stub_task_total("pending")
    end
 
    it "on Tasks tab: should remove task from current bucket and hide empty bucket" do
      request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render "tasks/update.js.rjs"

      response.body.should include_text(%Q/$("task_#{@task.id}").replace("")/)
      response.body.should include_text(%Q/$("list_due_asap").visualEffect("fade"/)
    end

    it "on Tasks tab: should show updated task in a new bucket" do
      request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render "tasks/update.js.rjs"
      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      response.should include_text('visualEffect("highlight"')
    end

    it "on Tasks tab: should update tasks sidebar" do
      request.env["HTTP_REFERER"] = "http://localhost/tasks"
      render "tasks/update.js.rjs"
      response.body.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
      end
      response.body.should include_text(%Q/$("filters").visualEffect("shake"/)
    end

    it "on asset landing page: should update task partial in place" do
      render "tasks/update.js.rjs"
      response.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
    end

    it "with invalid date:" do
    end
  end

  describe "Reassigning a task" do
    before(:each) do
    end

    it "no errors:" do
    end

    it "errors:" do
    end
  end

end