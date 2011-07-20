require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/new.js.rjs" do
  include CampaignsHelper
  
  before(:each) do
    login_and_assign
    assign(:campaign, Campaign.new(:user => @current_user))
    assign(:users, [ @current_user ])
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  it "should hide options form when called from Campaigns index" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
    render

    rendered.should include('crm.hide_form("options")')
  end

  describe "new campaign" do
    it "should render [new.html.haml] template into :create_campaign div" do
      params[:cancel] = nil
      render
    
      rendered.should have_rjs("create_campaign") do |rjs|
        with_tag("form[class=new_campaign]")
      end
    end

    it "should call JavaScript functions to load Calendar popup" do
      params[:cancel] = nil
      render

      rendered.should include('crm.flip_form("create_campaign")')
      rendered.should include('crm.date_select_popup("campaign_starts_on")')
      rendered.should include('crm.date_select_popup("campaign_ends_on")')
    end
  end
  
  describe "cancel new campaign" do
    it "should hide [create campaign] form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("create_campaign")
      rendered.should include('crm.flip_form("create_campaign")')
    end
  end

end


