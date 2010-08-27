require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/show.html.haml" do
  include ContactsHelper

  before(:each) do
    login_and_assign
    assign(:contact, Factory(:contact, :id => 42))
    assign(:users, [ @current_user ])
    assign(:comment, Comment.new)
  end

  it "should render contact landing page" do
    view.should_receive(:render).with(hash_including(:partial => "comments/new"))
    view.should_receive(:render).with(hash_including(:partial => "common/timeline"))
    view.should_receive(:render).with(hash_including(:partial => "common/tasks"))
    view.should_receive(:render).with(hash_including(:partial => "opportunities/opportunity"))

    render

    rendered.should have_tag("div[id=edit_contact]")
  end

end

