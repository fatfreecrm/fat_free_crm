require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/index.html.haml" do
  include TasksHelper
  
  before(:each) do
    @asap  = Factory(:task, :asset => Factory(:account), :bucket => "due_asap")
    @today = Factory(:task, :asset => Factory(:account), :bucket => "due_today")
  end

  VIEWS.each do |view|
    it "should render list of #{view} tasks if list of tasks is not empty" do
      assigns[:view] = view
      assigns[:tasks] = { :due_asap => [ @asap ], :due_today => [ @today ] }
      
      number_of_buckets = (view == "completed" ? Setting.task_completed : Setting.task_bucket).size
      template.should_receive(:render).with(hash_including(:partial => view)).exactly(number_of_buckets).times

      render "/tasks/index.html.haml"
    end
  end

end

