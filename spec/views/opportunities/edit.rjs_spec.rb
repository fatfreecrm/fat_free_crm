require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/opportunities/edit.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    
    assign(:opportunity, @opportunity = Factory(:opportunity, :user => @current_user))
    assign(:users, [ @current_user ])
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "cancel from opportunity index page: should replace [Edit Opportunity] form with opportunity partial" do
    params[:cancel] = "true"
    
    render
    rendered.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
      with_tag("li[id=opportunity_#{@opportunity.id}]")
    end
  end

  it "cancel from opportunity landing page: should hide [Edit Opportunity] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
    params[:cancel] = "true"
    
    render
    rendered.should include('crm.flip_form("edit_opportunity"')
  end

  it "edit: should hide previously open [Edit Opportunity] for and replace it with opportunity partial" do
    params[:cancel] = nil
    assign(:previous, previous = Factory(:opportunity, :user => @current_user))

    render
    rendered.should have_rjs("opportunity_#{previous.id}") do |rjs|
      with_tag("li[id=opportunity_#{previous.id}]")
    end
  end

  it "edit: remove previously open [Edit Opportunity] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include(%Q/crm.flick("opportunity_#{previous}", "remove");/)
  end
  
  it "edit from opportunities index page: should turn off highlight, hide [Create Opportunity] form, and replace current opportunity with [Edit Opportunity] form" do
    params[:cancel] = nil
    
    render
    rendered.should include(%Q/crm.highlight_off("opportunity_#{@opportunity.id}");/)
    rendered.should include('crm.hide_form("create_opportunity")')
    rendered.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
      with_tag("form[class=edit_opportunity]")
    end
  end
  
  it "edit from opportunity landing page: should show [Edit Opportunity] form" do
    params[:cancel] = "false"
    
    render
    rendered.should have_rjs("edit_opportunity") do |rjs|
      with_tag("form[class=edit_opportunity]")
    end
    rendered.should include('crm.flip_form("edit_opportunity"')
  end
  
  it "edit: should handle new or existing account for the opportunity" do

    render
    rendered.should include("crm.create_or_select_account")
  end

end
