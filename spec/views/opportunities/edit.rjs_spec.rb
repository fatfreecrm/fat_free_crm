require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/opportunities/edit.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:opportunity] = Factory(:opportunity, :id => 42, :user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:stage] = {}
  end

  it "cancel from opportunity index page: should replace [Edit Opportunity] form with opportunity partial" do
    params[:cancel] = "true"
    
    render "opportunities/edit.js.rjs"
    response.should have_rjs("opportunity_42") do |rjs|
      with_tag("li[id=opportunity_42]")
    end
  end

  it "cancel from opportunity landing page: should hide [Edit Opportunity] form" do
    request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
    params[:cancel] = "true"
    
    render "opportunities/edit.js.rjs"
    response.should include_text('crm.flip_form("edit_opportunity"')
  end

  it "edit: should hide previously open [Edit Opportunity] for and replace it with opportunity partial" do
    params[:cancel] = nil
    assigns[:previous] = Factory(:opportunity, :id => 41, :user => @current_user)

    render "opportunities/edit.js.rjs"
    response.should have_rjs("opportunity_41") do |rjs|
      with_tag("li[id=opportunity_41]")
    end
  end

  it "edit: remove previously open [Edit Opportunity] if it's no longer available" do
    params[:cancel] = nil
    assigns[:previous] = 41

    render "opportunities/edit.js.rjs"
    response.should include_text(%Q/crm.flick("opportunity_41", "remove");/)
  end
  
  it "edit from opportunities index page: should turn off highlight and replace current opportunity with [Edit Opportunity] form" do
    params[:cancel] = nil
    
    render "opportunities/edit.js.rjs"
    response.should include_text('crm.highlight_off("opportunity_42");')
    response.should have_rjs("opportunity_42") do |rjs|
      with_tag("form[class=edit_opportunity]")
    end
  end
  
  it "edit from opportunity landing page: should show [Edit Opportunity] form" do
    params[:cancel] = "false"
    
    render "opportunities/edit.js.rjs"
    response.should have_rjs("edit_opportunity") do |rjs|
      with_tag("form[class=edit_opportunity]")
    end
    response.should include_text('crm.flip_form("edit_opportunity"')
  end
  
  it "edit: should handle new or existing account for the opportunity" do

    render "opportunities/edit.js.rjs"
    response.should include_text("crm.create_or_select_account")
  end

end
