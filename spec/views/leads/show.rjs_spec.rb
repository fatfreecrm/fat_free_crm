require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = Factory(:lead, :id => 42)
    assigns[:users] = [ @current_user ]
    assigns[:comment] = Comment.new
  end

  it "should render lead landing page" do
    view.should_receive(:render).with(hash_including(:partial => "comments/new"))
    view.should_receive(:render).with(hash_including(:partial => "common/timeline"))
    view.should_receive(:render).with(hash_including(:partial => "common/tasks"))

    render
    rendered.should have_tag("div[id=edit_lead]")
  end

end

