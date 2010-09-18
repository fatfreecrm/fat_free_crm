require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/destroy.js.rjs" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  TASK_STATUSES.each do |status|
    describe "destroy from Tasks tab (#{status} view)" do
      before(:each) do
        @task = Factory(:task)
        assign(:task, @task)
        assign(:view, status)
        assign(:empty_bucket, :due_asap)
        assign(:task_total, stub_task_total(status))
      end

      it "should blind up out destroyed task partial" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render
        rendered.should include(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
        rendered.should include(%Q/$("list_due_asap").visualEffect("fade"/)
      end

      it "should update tasks sidebar" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/tasks"

        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        rendered.should include(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end

  describe "destroy from related asset" do
    it "should blind up out destroyed task partial" do
      @task = Factory(:task)
      assign(:task, @task)
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"

      render
      rendered.should include(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
      rendered.should_not include(%Q/$("list_due_asap").visualEffect("fade"/) # bucket is not empty
    end
  end
end
