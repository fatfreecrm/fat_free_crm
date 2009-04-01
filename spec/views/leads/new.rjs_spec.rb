require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/new.html.haml" do
  include LeadsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @campaign = Factory(:campaign)
    assigns[:lead] = Lead.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:campaign] = @campaign
    assigns[:campaigns] = [ @campaign ]
  end
 
  it "create: should render [new.html.haml] template into :create_lead div" do
    params[:cancel] = nil
    render "leads/new.js.rjs"

    response.should have_rjs("create_lead") do |rjs|
      with_tag("form[class=new_lead]")
    end
    response.should include_text('crm.flip_form("create_lead")')
  end

  it "cancel: should render [new.html.haml] template into :create_lead div" do
    params[:cancel] = "true"
    render "leads/new.js.rjs"

    response.should_not have_rjs("create_lead")
    response.should have_text('crm.flip_form("create_lead");')
  end

end


