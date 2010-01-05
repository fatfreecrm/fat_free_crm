require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_edit.html.haml" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assigns[:account] = @account = Factory(:account)
    assigns[:accounts] = [ @account ]
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end

  it "should render [edit opportunity] form" do
    assigns[:users] = [ @current_user ]
    assigns[:opportunity] = @opportunity = Factory(:opportunity, :campaign => @campaign = Factory(:campaign))
    render "/opportunities/_edit.html.haml"

    response.should have_tag("form[class=edit_opportunity]") do
      with_tag "input[type=hidden][id=opportunity_user_id][value=#{@opportunity.user_id}]"
      with_tag "input[type=hidden][id=opportunity_campaign_id][value=#{@opportunity.campaign_id}]"
    end
  end

  it "should pick default assignee (Myself)" do
    assigns[:users] = [ @current_user ]
    assigns[:opportunity] = Factory(:opportunity, :assignee => nil)
    render "/opportunities/_edit.html.haml"

    response.should have_tag("select[id=opportunity_assigned_to]") do |options|
      options.to_s.should_not include_text(%Q/selected="selected"/)
    end
  end

  it "should show correct assignee" do
    @user = Factory(:user)
    assigns[:users] = [ @current_user, @user ]
    assigns[:opportunity] = Factory(:opportunity, :assignee => @user)
    render "/opportunities/_edit.html.haml"

    response.should have_tag("select[id=opportunity_assigned_to]") do |options|
      with_tag "option[selected=selected]"
      with_tag "option[value=#{@user.id}]"
    end
  end

end


