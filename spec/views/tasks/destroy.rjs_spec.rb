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
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render
        rendered.should include_text(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
        rendered.should include_text(%Q/$("list_due_asap").visualEffect("fade"/)
      end

      it "should update tasks sidebar" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        rendered.should include_text(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end

  describe "destroy from related asset" do
    it "should blind up out destroyed task partial" do
      @task = Factory(:task)
      assigns[:task] = @task
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"

      render
      rendered.should include_text(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
      rendered.should_not include_text(%Q/$("list_due_asap").visualEffect("fade"/) # bucket is not empty
    end
  end

end
