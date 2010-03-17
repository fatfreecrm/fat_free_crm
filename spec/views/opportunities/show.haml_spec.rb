require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assigns[:opportunity] = Factory(:opportunity, :id => 42)
    assigns[:users] = [ @current_user ]
    assigns[:comment] = Comment.new
  end

  it "should render opportunity landing page" do
    template.should_receive(:render).with(hash_including(:partial => "comments/new"))
    template.should_receive(:render).with(hash_including(:partial => "comments/comment"))
    template.should_receive(:render).with(hash_including(:partial => "contacts/contact"))

    render "/opportunities/show.html.haml"

    response.should have_tag("div[id=edit_opportunity]")
  end

end

