require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/tasks/destroy.js.rjs" do
  include TasksHelper

  def stub_task_total(view = "pending")
    settings = (view == "completed" ? Setting.task_completed : Setting.task_due_at_hint)
    settings.inject({ :all => 0 }) { |hash, (value, key)| hash[key] = 1; hash }
  end

  # @task = Task.find(params[:id])
  # @task.destroy
  # @view = params[:view] || "pending"
  # 
  # # Make sure bucket's div gets hidden if we're deleting last task in the bucket.
  # @bucket = Task.bucket(@current_user, params[:bucket],  @view)
  # 
  # update_sidebar if request.referer =~ /\/tasks\?*/ && !params[:bucket].blank?

  for view in VIEWS do
    describe "destroy from Tasks tab (#{view} view)" do
      before(:each) do
        @task = Factory(:task)
        assigns[:task] = @task
        assigns[:view] = view
        assigns[:bucket] = params[:bucket] = :due_asap
        assigns[:task_total] = stub_task_total(view)
      end

      it "should blind up out destroyd task partial" do
        render "tasks/destroy.js.rjs"
        response.body.should include_text(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
        response.body.should include_text(%Q/$("list_due_asap").visualEffect("fade"/)
      end
  
      it "should update tasks sidebar" do
        render "tasks/destroy.js.rjs"
        response.body.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
        end
        response.body.should include_text(%Q/$("filters").visualEffect("shake"/)
      end
    end
  end
  
  describe "destroy from related asset" do
    it "should blind up out destroyd task partial, but not update sidebar" do
      @task = Factory(:task)
      assigns[:task] = @task
      request.env["HTTP_REFERER"] = "http://localhost/leads/123"
  
      render "tasks/destroy.js.rjs"
      response.body.should include_text(%Q/$("task_#{@task.id}").visualEffect("blind_up"/)
      response.body.should_not include_text(%Q/$("list_due_asap").visualEffect("fade"/)
      response.body.should_not have_rjs("sidebar")
    end
  end

end
