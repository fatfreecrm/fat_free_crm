require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/index.html.haml" do
  include TasksHelper

  before(:each) do
    login_and_assign
  end

  VIEWS.each do |status|
    before(:each) do
      @asap  = Factory(:task, :asset => Factory(:account), :bucket => "due_asap")
      @today = Factory(:task, :asset => Factory(:account), :bucket => "due_today")
    end

    it "should render list of #{status} tasks if list of tasks is not empty" do
      assign(:view, status)
      assign(:tasks, { :due_asap => [ @asap ], :due_today => [ @today ] })

      render

      number_of_buckets = (status == "completed" ? Setting.task_completed : Setting.task_bucket).size
      view.should render_template(:partial => "_" << status).exactly(number_of_buckets).times
      view.should_not render_template(:partial => "_empty")
    end
  end

  VIEWS.each do |status|
    it "should render a message if there're no #{status} tasks" do
      assign(:view, status)
      assign(:tasks, { :due_asap => [], :due_today => [] })

      render

      view.should render_template(:partial => "_empty")
    end
  end

end

