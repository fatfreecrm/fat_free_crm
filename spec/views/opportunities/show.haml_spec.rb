require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/show.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assign(:opportunity, Factory(:opportunity, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
  end

  it "should render opportunity landing page" do
    view.should_receive(:render).with(hash_including(:partial => "comments/new"))
    view.should_receive(:render).with(hash_including(:partial => "common/timeline"))
    view.should_receive(:render).with(hash_including(:partial => "common/tasks"))
    view.should_receive(:render).with(hash_including(:partial => "contacts/contact"))

    render

    rendered.should have_tag("div[id=edit_opportunity]")
  end

end

