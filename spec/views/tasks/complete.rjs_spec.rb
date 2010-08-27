require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/edit.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  describe "complete from Tasks tab (pending view)" do
    before(:each) do
      @task = Factory(:task)
      assign(:task, @task)
      assign(:view, "pending")
      assign(:empty_bucket, :due_asap)
      assign(:task_total, stub_task_total("pending"))
    end

    it "should fade out completed task partial" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should match(%Q/$("task_#{@task.id}").visualEffect("fade"/)
      rendered.should match(%Q/$("list_due_asap").visualEffect("fade"/)
    end

    it "should update tasks sidebar" do
      assign(:task, Factory(:task))
      assign(:view, "pending")
      assign(:empty_bucket, :due_asap)
      controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render
      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
      rendered.should match(%Q/$("filters").visualEffect("shake"/)
    end
  end
  
  describe "complete from related asset" do
    it "should replace pending partial with the completed one" do
      @task = Factory(:task, :completed_at => Time.now, :completor => @current_user)
      assign(:task, @task)

      render
      rendered.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      rendered.should match('<strike>')
    end

    it "should update recently viewed items" do
      @task = Factory(:task, :completed_at => Time.now, :completor => @current_user)
      assign(:task, @task)
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
  
      render
      rendered.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end
  end

end
