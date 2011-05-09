require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/index.html.haml" do
  include HomeHelper
  
  before(:each) do
    login_and_assign
    assigns[:my_tasks] = []
    assigns[:my_opportunities] = []
    assigns[:my_accounts] = []
    assigns[:activities] = []
  end

  context "activities" do
    it "should render list of activities if it's not empty" do
      assigns[:activities] = [ Factory(:activity, :action => "updated", :subject => Factory(:account)) ]
      template.should_receive(:render).with(hash_including(:partial => "activity"))
      render "/home/index.html.haml"
    end

    it "should render a message if there're no activities" do
      assigns[:activities] = []
      template.should_not_receive(:render).with(hash_including(:partial => "activity"))

      render "/home/index.html.haml"
      response.body.should include("No activity records found.")
    end
  end
  
  context "tasks" do
    it "should render list of tasks if it's not empty" do
      assigns[:my_tasks] = [Factory(:task)]
      template.should_receive(:render).with(hash_including(:partial => "home/task"))
      render "/home/index.html.haml"
    end

    it "should render a message if there're no tasks" do
      assigns[:my_tasks] = []
      template.should_not_receive(:render).with(hash_including(:partial => "home/task"))

      render "/home/index.html.haml"
      response.body.should include(t(:no_task_records))
    end
  end
  
  context "opportunities" do
    it "should render list of opportunities if it's not empty" do
      assigns[:my_opportunities] = [Factory(:opportunity)]
      template.should_receive(:render).with(hash_including(:partial => "home/opportunity"))
      render "/home/index.html.haml"
    end

    it "should render a message if there're no opportunities" do
      assigns[:my_opportunities] = []
      template.should_not_receive(:render).with(hash_including(:partial => "home/opportunity"))

      render "/home/index.html.haml"
      response.body.should include(t(:no_opportunity_records))
    end
  end
  
  context "accounts" do
    it "should render list of accounts if it's not empty" do
      assigns[:my_accounts] = [Factory(:account)]
      template.should_receive(:render).with(hash_including(:partial => "home/account"))
      render "/home/index.html.haml"
    end

    it "should render a message if there're no accounts" do
      assigns[:my_accounts] = []
      template.should_not_receive(:render).with(hash_including(:partial => "home/account"))

      render "/home/index.html.haml"
      response.body.should include(t(:no_account_records))
    end
  end
end

