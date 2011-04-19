require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/common/add_tag.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:owner] = @lead = Factory(:lead, :user => @current_user, :tag_list => "moo, foo, bar")
  end

  it "updates the tags" do
    render "common/add_tag.js.rjs"
    # Not understand how the rjs matchers work...
    response.should have_rjs
  end
end
