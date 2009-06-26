require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/leads/edit.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead, :status => "new", :user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:campaigns] = [ Factory(:campaign) ]
  end

  it "cancel from lead index page: should replace [Edit Lead] form with lead partial" do
    params[:cancel] = "true"
    
    render "leads/edit.js.rjs"
    response.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("li[id=lead_#{@lead.id}]")
    end
  end

  it "cancel from lead landing page: should hide [Edit Lead] form" do
    request.env["HTTP_REFERER"] = "http://localhost/leads/123"
    params[:cancel] = "true"
    
    render "leads/edit.js.rjs"
    response.should include_text('crm.flip_form("edit_lead"')
  end

  it "edit: should hide previously open [Edit Lead] and replace it with lead partial" do
    params[:cancel] = nil
    assigns[:previous] = previous = Factory(:lead, :user => @current_user)

    render "leads/edit.js.rjs"
    response.should have_rjs("lead_#{previous.id}") do |rjs|
      with_tag("li[id=lead_#{previous.id}]")
    end
  end

  it "edit: should remove previously open [Edit Lead] if it's no longer available" do
    params[:cancel] = nil
    assigns[:previous] = previous = 41

    render "leads/edit.js.rjs"
    response.should include_text(%Q/crm.flick("lead_#{previous}", "remove");/)
  end
  
  it "edit from leads index page: should turn off highlight, hide [Create Lead] form, and replace current lead with [Edit Lead] form" do
    params[:cancel] = nil
    
    render "leads/edit.js.rjs"
    response.should include_text(%Q/crm.highlight_off("lead_#{@lead.id}");/)
    response.should include_text('crm.hide_form("create_lead")')
    response.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("form[class=edit_lead]")
    end
  end
  
  it "edit from lead landing page: should hide [Convert Lead] and show [Edit Lead] form" do
    params[:cancel] = "false"
    
    render "leads/edit.js.rjs"
    response.should have_rjs("edit_lead") do |rjs|
      with_tag("form[class=edit_lead]")
    end
    response.should include_text('crm.hide_form("convert_lead"')
    response.should include_text('crm.flip_form("edit_lead"')
  end

  it "edit from lead landing page: should not attempt to hide [Convert Lead] if the lead is already converted" do
    params[:cancel] = "false"
    assigns[:lead] = Factory(:lead, :status => "converted", :user => @current_user)

    render "leads/edit.js.rjs"
    response.should_not include_text('crm.hide_form("convert_lead"')
  end

end
