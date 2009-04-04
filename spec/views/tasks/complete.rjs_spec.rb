require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/edit.js.rjs" do
  include TasksHelper

  describe "complete from Tasks tab (pending view)" do
    before(:each) do
      @task = Factory(:task)
      assigns[:task] = @task
      assigns[:view] = "pending"
      assigns[:bucket] = params[:bucket] = :due_asap
      assigns[:task_total] = Setting.task_bucket.inject({ :all => 0 }) { |hash, (value, key)| hash[key] = 1; hash }
    end

    it "should fade out completed task partial" do
      render "tasks/complete.js.rjs"
      response.body.should include_text(%Q/$("task_#{@task.id}").visualEffect("fade"/)
      response.body.should include_text(%Q/$("list_due_asap").visualEffect("fade"/)
    end

    it "should update tasks sidebar" do
      assigns[:task] = Factory(:task)
      assigns[:view] = "pending"
      assigns[:bucket] = params[:bucket] = :due_asap

      render "tasks/complete.js.rjs"
      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
      end
      response.body.should include_text(%Q/$("filters").visualEffect("shake"/)
    end
  end
  
  describe "complete from related asset" do
    it "should replace pending partial with the completed one" do
      @task = Factory(:task, :completed_at => Time.now)
      assigns[:task] = @task
      assigns[:current_user] = Factory(:user)

      render "tasks/complete.js.rjs"
      response.should have_rjs("task_#{@task.id}") do |rjs|
        with_tag("li[id=task_#{@task.id}]")
      end
      response.body.should include_text('<strike>')
    end
  end

end
