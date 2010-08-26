require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_create.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assigns[:opportunity] = Factory.build(:opportunity)
    @account = Factory(:account)
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:users] = [ @current_user ]
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end

  it "should render [create opportunity] form" do
    view.should_receive(:render).with(hash_including(:partial => "opportunities/top_section"))
    view.should_receive(:render).with(hash_including(:partial => "opportunities/permissions"))

    render
    rendered.should have_tag("form[class=new_opportunity]")
  end

  it "should pick default assignee (Myself)" do
    render
    rendered.should have_tag("select[id=opportunity_assigned_to]") do |options|
      options.to_s.should_not include_text(%Q/selected="selected"/)
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


