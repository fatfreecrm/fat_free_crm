require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = Factory(:lead, :id => 42, :tag_list => "foo, bar")
    assigns[:users] = [ @current_user ]
    assigns[:comment] = Comment.new
  end

  it "should render lead landing page" do
    template.should_receive(:render).with(hash_including(:partial => "comments/new"))
    template.should_receive(:render).with(hash_including(:partial => "common/timeline"))
    template.should_receive(:render).with(hash_including(:partial => "common/tasks"))
    template.should_receive(:render).with(hash_including(:partial => "common/tags"))

    render "/leads/show.html.haml"
    response.should have_tag("div[id=edit_lead]")
  end
end

