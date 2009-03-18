require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/index.html.erb" do
  include TasksHelper
  
  before(:each) do
    @asap = Factory(:task, :asset => Factory(:account), :due_at_hint => "due_asap")
    @today = Factory(:task, :asset => Factory(:account), :due_at_hint => "due_today")
  end

  it "should render list of accounts if list of tasks is not empty" do
    assigns[:view] = "pending"
    assigns[:tasks] = { :due_asap => [ @asap ], :due_today => [ @today ] }
    template.should_receive(:render).with(hash_including(:partial => "pending")).at_least(:once)
    render "/tasks/index.html.haml"
  end

end

