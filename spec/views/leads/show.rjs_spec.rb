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
    template.should_receive(:render).with(hash_including(:partial => "common/new_comment"))
    template.should_receive(:render).with(hash_including(:partial => "common/comment"))

    render "/leads/show.html.haml"
    response.should have_tag("div[id=edit_lead]")
  end

end

