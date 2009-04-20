require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/new.html.erb" do
  include CampaignsHelper
  
  before(:each) do
    login_and_assign
    assigns[:campaign] = Campaign.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
  end
 
  it "create: should render [new.html.haml] template into :create_campaign div" do
    params[:cancel] = nil
    render "campaigns/new.js.rjs"
    
    response.should have_rjs("create_campaign") do |rjs|
      with_tag("form[class=new_campaign]")
    end
  end

  it "create: should call JavaScript functions to load Calendar popup" do
    params[:cancel] = nil
    render "campaigns/new.js.rjs"

    response.should include_text('crm.flip_form("create_campaign")')
    response.should include_text('crm.date_select_popup("campaign_starts_on")')
    response.should include_text('crm.date_select_popup("campaign_ends_on")')
  end

  it "cancel: should render [new.html.haml] template into :create_campaign div" do
    params[:cancel] = "true"
    render "leads/new.js.rjs"

    response.should_not have_rjs("create_campaign")
  end

end


