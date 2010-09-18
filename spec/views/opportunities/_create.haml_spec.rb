require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_create.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assign(:opportunity, Factory.build(:opportunity))
    @account = Factory(:account)
    assign(:account, @account)
    assign(:accounts, [ @account ])
    assign(:users, [ @current_user ])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render [create opportunity] form" do
    render
    view.should render_template(:partial => "opportunities/_top_section")
    view.should render_template(:partial => "opportunities/_permissions")

    rendered.should have_tag("form[class=new_opportunity]")
  end

  it "should pick default assignee (Myself)" do
    render
    rendered.should have_tag("select[id=opportunity_assigned_to]") do |options|
      options.to_s.should_not include(%Q/selected="selected"/)
    end
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :opportunity ]

    render
    rendered.should have_tag("textarea[id=opportunity_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=opportunity_background_info]")
  end
end


