require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/opportunities/update.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account, :id => 987654)
    @opportunity = Factory(:opportunity, :id => 42, :user => @current_user, :assignee => Factory(:user))
    assigns[:opportunity] = @opportunity
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:stage] = Setting.as_hash(:opportunity_stage)
    assigns[:opportunity_stage_total] = {:prospecting=>10, :final_review=>1, :qualification=>1, :won=>2, :all=>20, :analysis=>1, :lost=>0, :presentation=>2, :other=>0, :proposal=>1, :negotiation=>2}
  end
 
  it "no errors: should flip [edit_opportunity] form when called from opportunity landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"

    render "opportunities/update.js.rjs"
    response.should_not have_rjs("opportunity_42")
    response.should include_text('crm.flip_form("edit_opportunity"')
  end

  it "no errors: should update sidebar when called from opportunity landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"

    render "opportunities/update.js.rjs"
    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=summary]")
      with_tag("div[id=recently]")
    end
    response.should include_text('$("summary").visualEffect("shake"')
  end
 
  it "no errors: should replace [Edit Opportunity] with opportunity partial and highligh it when called outside opportunity landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/opportunities"

    render "opportunities/update.js.rjs"
    response.should have_rjs("opportunity_42") do |rjs|
      with_tag("li[id=opportunity_42]")
    end
    response.should include_text('$("opportunity_42").visualEffect("highlight"')
  end
 
  it "errors: should redraw the [edit_opportunity] form and shake it" do
    @opportunity.errors.add(:error)

    render "opportunities/update.js.rjs"
    response.should have_rjs("opportunity_42") do |rjs|
      with_tag("form[class=edit_opportunity]")
    end
    response.should include_text('crm.create_or_select_account(false)')
    response.should include_text('$("opportunity_42").visualEffect("shake"')
    response.should include_text('focus()')
  end

  it "errors: should show disabled accounts dropdown when called from accounts landing page" do
    @opportunity.errors.add(:error)
    request.env["HTTP_REFERER"] = ref = "http://localhost/accounts/123"

    render "opportunities/update.js.rjs"
    response.should include_text("crm.create_or_select_account(#{ref =~ /\/accounts\//})")
  end

end