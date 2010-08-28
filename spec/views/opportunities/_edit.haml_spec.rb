require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_edit.html.haml" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render [edit opportunity] form" do
    assign(:users, [ @current_user ])
    assign(:opportunity, @opportunity = Factory(:opportunity, :campaign => @campaign = Factory(:campaign)))
    render

    rendered.should have_tag("form[class=edit_opportunity]") do
      with_tag "input[type=hidden][id=opportunity_user_id][value=#{@opportunity.user_id}]"
      with_tag "input[type=hidden][id=opportunity_campaign_id][value=#{@opportunity.campaign_id}]"
    end
  end

  it "should pick default assignee (Myself)" do
    assign(:users, [ @current_user ])
    assign(:opportunity, Factory(:opportunity, :assignee => nil))
    render

    rendered.should have_tag("select[id=opportunity_assigned_to]") do |options|
      options.to_s.should_not include(%Q/selected="selected"/)
    end
  end

  it "should show correct assignee" do
    @user = Factory(:user)
    assign(:users, [ @current_user, @user ])
    assign(:opportunity, Factory(:opportunity, :assignee => @user))
    render

    rendered.should have_tag("select[id=opportunity_assigned_to]") do |options|
      with_tag "option[selected=selected]"
      with_tag "option[value=#{@user.id}]"
    end
  end

  it "should render background info field if settings require so" do
    assign(:users, [ @current_user ])
    assign(:opportunity, Factory(:opportunity))
    Setting.background_info = [ :opportunity ]

    render
    rendered.should have_tag("textarea[id=opportunity_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    assign(:users, [ @current_user ])
    assign(:opportunity, Factory(:opportunity))
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=opportunity_background_info]")
  end
end
