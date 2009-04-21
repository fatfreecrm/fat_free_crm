require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/leads/convert.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:lead] = Factory(:lead, :id => 42, :user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:opportunity] = Factory(:opportunity)
  end

  it "cancel from lead index page: should replace [Convert Lead] form with lead partial" do
    params[:cancel] = "true"
    
    render "leads/convert.js.rjs"
    response.should have_rjs("lead_42") do |rjs|
      with_tag("li[id=lead_42]")
    end
  end

  it "cancel from lead landing page: should hide [Convert Lead] form" do
    request.env["HTTP_REFERER"] = "http://localhost/leads/123"
    params[:cancel] = "true"
    
    render "leads/convert.js.rjs"
    response.should include_text('crm.flip_form("convert_lead"')
  end
  
  it "convert: should hide previously open [Convert Lead] and replace it with lead partial" do
    params[:cancel] = nil
    assigns[:previous] = Factory(:lead, :id => 41, :user => @current_user)
    
    render "leads/convert.js.rjs"
    response.should have_rjs("lead_41") do |rjs|
      with_tag("li[id=lead_41]")
    end
  end
  
  it "convert from leads index page: should turn off highlight and replace current lead with [Convert Lead] form" do
    params[:cancel] = nil
    
    render "leads/convert.js.rjs"
    response.should include_text('crm.highlight_off("lead_42");')
    response.should have_rjs("lead_42") do |rjs|
      with_tag("form[class=edit_lead]")
    end
  end
  
  it "convert from lead landing page: should hide [Edit Lead] and show [Convert Lead] form" do
    params[:cancel] = "false"
    
    render "leads/convert.js.rjs"
    response.should have_rjs("convert_lead") do |rjs|
      with_tag("form[class=edit_lead]")
    end
    response.should include_text('crm.hide_form("edit_lead"')
    response.should include_text('crm.flip_form("convert_lead"')
  end

  it "convert: should handle new or existing account and set up calendar field" do
    params[:cancel] = "false"

    render "leads/convert.js.rjs"
    response.should include_text("crm.create_or_select_account")
    response.should include_text('crm.date_select_popup("opportunity_closes_on")')
    response.should include_text('$("account_name").focus()')
  end

end
