require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/leads/convert.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    
    assign(:lead, @lead = Factory(:lead, :user => @current_user))
    assign(:users, [ @current_user ])
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
    assign(:opportunity, Factory(:opportunity))
  end

  it "cancel from lead index page: should replace [Convert Lead] form with lead partial" do
    params[:cancel] = "true"
    
    render
    rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("li[id=lead_#{@lead.id}]")
    end
  end

  it "cancel from lead landing page: should hide [Convert Lead] form" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
    params[:cancel] = "true"

    render
    rendered.should include('crm.flip_form("convert_lead"')
  end
  
  it "convert: should hide previously open [Convert Lead] and replace it with lead partial" do
    params[:cancel] = nil
    assign(:previous, previous = Factory(:lead, :user => @current_user))

    render
    rendered.should have_rjs("lead_#{previous.id}") do |rjs|
      with_tag("li[id=lead_#{previous.id}]")
    end
  end

  it "convert: should remove previously open [Convert Lead] if it's no longer available" do
    params[:cancel] = nil
    assign(:previous, previous = 41)

    render
    rendered.should include(%Q/crm.flick("lead_#{previous}", "remove");/)
  end
  
  it "convert from leads index page: should turn off highlight, hide [Create Lead] form, and replace current lead with [Convert Lead] form" do
    params[:cancel] = nil
    
    render
    rendered.should include(%Q/crm.highlight_off("lead_#{@lead.id}");/)
    rendered.should include('crm.hide_form("create_lead")')
    rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("form[class=edit_lead]")
    end
  end
  
  it "convert from lead landing page: should hide [Edit Lead] and show [Convert Lead] form" do
    params[:cancel] = "false"
    
    render
    rendered.should have_rjs("convert_lead") do |rjs|
      with_tag("form[class=edit_lead]")
    end
    rendered.should include('crm.hide_form("edit_lead"')
    rendered.should include('crm.flip_form("convert_lead"')
  end

  it "convert: should handle new or existing account and set up calendar field" do
    params[:cancel] = "false"

    render
    rendered.should include("crm.create_or_select_account")
    rendered.should include('crm.date_select_popup("opportunity_closes_on")')
    rendered.should include('$("account_name").focus()')
  end

end
