require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/new.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    @campaign = Factory(:campaign)
    assigns[:lead] = Lead.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:campaign] = @campaign
    assigns[:campaigns] = [ @campaign ]
  end

  it "should toggle empty message div if it exists" do
    render "leads/new.js.rjs"

    response.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide options form when called from Leads index" do
    request.env["HTTP_REFERER"] = "http://localhost/leads"
    render "leads/new.js.rjs"

    response.should include_text('crm.hide_form("options")')
  end

  describe "new lead" do
    it "should render [new.html.haml] template into :create_lead div" do
      params[:cancel] = nil
      render "leads/new.js.rjs"

      response.should have_rjs("create_lead") do |rjs|
        with_tag("form[class=new_lead]")
      end
      response.should include_text('crm.flip_form("create_lead")')
    end
  end

  describe "cancel new lead" do
    it "should hide [create_lead] form" do
      params[:cancel] = "true"
      render "leads/new.js.rjs"

      response.should_not have_rjs("create_lead")
      response.should include_text('crm.flip_form("create_lead");')
    end
  end

end


