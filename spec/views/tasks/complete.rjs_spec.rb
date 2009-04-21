require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/edit.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  describe "complete from Tasks tab (pending view)" do
    before(:each) do
      @task = Factory(:task)
      assigns[:task] = @task
      assigns[:view] = "pending"
      assigns[:empty_bucket] = :due_asap
      assigns[:task_total] = Setting.task_bucket.inject({ :all => 0 }) { |hash, (value, key)| hash[key] = 1; hash }
    end

    it "should fade out completed task partial" do
      request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render "tasks/complete.js.rjs"
      response.should include_text(%Q/$("task_#{@task.id}").visualEffect("fade"/)
      response.should include_text(%Q/$("list_due_asap").visualEffect("fade"/)
    end

    it "should update tasks sidebar" do
      assigns[:task] = Factory(:task)
      assigns[:view] = "pending"
      assigns[:empty_bucket] = :due_asap
      request.env["HTTP_REFERER"] = "http://localhost/tasks"

      render "tasks/complete.js.rjs"
      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
      response.should include_text(%Q/$("filters").visualEffect("shake"/)
    end
  end
  
  describe "complete from related asset" do
    it "should replace pending partial with the completed one" do
      @task = Factory(:task, :completed_at => Time.now)
      assigns[:task] = @task

      render "tasks/complete.js.rjs"
      response.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      response.should include_text('<strike>')
    end

    it "should update recently viewed items" do
      @task = Factory(:task, :completed_at => Time.now)
      assigns[:task] = @task
      request.env["HTTP_REFERER"] = "http://localhost/leads/123"
  
      render "tasks/complete.js.rjs"
      response.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end
  end

end
