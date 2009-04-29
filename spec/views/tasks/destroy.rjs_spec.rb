require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/destroy.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  VIEWS.each do |view|
    describe "destroy from Tasks tab (#{view} view)" do
      before(:each) do
        @task = Factory(:task)
        assigns[:task] = @task
        assigns[:view] = view
        assigns[:empty_bucket] = :due_asap
        assigns[:task_total] = stub_task_total(view)
      end

      it "should blind up out destroyed task partial" do
        request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render "tasks/destroy.js.rjs"
        response.should include_text(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
        response.should include_text(%Q/$("list_due_asap").visualEffect("fade"/)
      end
  
      it "should update tasks sidebar" do
        request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render "tasks/destroy.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        response.should include_text(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end
  
  describe "destroy from related asset" do
    it "should blind up out destroyed task partial" do
      @task = Factory(:task)
      assigns[:task] = @task
      request.env["HTTP_REFERER"] = "http://localhost/leads/123"
  
      render "tasks/destroy.js.rjs"
      response.should include_text(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
      response.should_not include_text(%Q/$("list_due_asap").visualEffect("fade"/) # bucket is not empty
    end
  end

end
