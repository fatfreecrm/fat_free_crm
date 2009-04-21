require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/leads/edit.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    assigns[:lead] = Factory(:lead, :id => 42, :status => "new", :user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:campaigns] = [ Factory(:campaign) ]
  end

  it "cancel from lead index page: should replace [Edit Lead] form with lead partial" do
    params[:cancel] = "true"
    
    render "leads/edit.js.rjs"
    response.should have_rjs("lead_42") do |rjs|
      with_tag("li[id=lead_42]")
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
    assigns[:previous] = Factory(:lead, :id => 41, :user => @current_user)
    
    render "leads/edit.js.rjs"
    response.should have_rjs("lead_41") do |rjs|
      with_tag("li[id=lead_41]")
    end
  end
  
  it "edit from leads index page: should turn off highlight and replace current lead with [Edit Lead] form" do
    params[:cancel] = nil
    
    render "leads/edit.js.rjs"
    response.should include_text('crm.highlight_off("lead_42");')
    response.should have_rjs("lead_42") do |rjs|
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
