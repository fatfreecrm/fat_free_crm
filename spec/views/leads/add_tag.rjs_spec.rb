require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/add_tag.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead, :user => @current_user, :tag_list => "moo, foo, bar")
    assigns[:users] = [ Factory(:campaign) ]
    assigns[:campaigns] = [ Factory(:campaign) ]
    assigns[:lead_status_total] = { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 }
  end

  it "updates the tags" do
    render "leads/add_tag.js.rjs"
    # Not understand how the rjs matchers work...
    response.should have_rjs
  end
end
