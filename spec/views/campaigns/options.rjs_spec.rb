require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/options.rjs" do
  include CampaignsHelper
  
  before(:each) do
    login_and_assign
    assigns[:sort_by]  = "campaigns.name ASC"
    assigns[:outline]  = "option_long"
    assigns[:per_page] = 20
  end

  it "should toggle empty message div if it exists" do
    render "campaigns/options.js.rjs"

    response.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide [Create Campaign] form if it's visible" do
    render "campaigns/options.js.rjs"

    response.should include_text('crm.hide_form("create_campaign")')
  end

  describe "campaign options" do
    it "should render [options.html.haml] template into :options div and show it" do
      params[:cancel] = nil
      render "campaigns/options.js.rjs"
    
      response.should have_rjs("options") do |rjs|
        with_tag("input[type=hidden]") # @current_user
      end
      response.should include_text('crm.flip_form("options")')
      response.should include_text('crm.set_title("create_campaign", "Campaigns Options")')
    end

    it "should call JavaScript functions to load preferences menus" do
      params[:cancel] = nil
      template.should_receive(:render).with(:partial => "common/sort_by")
      template.should_receive(:render).with(:partial => "common/per_page")
      template.should_receive(:render).with(:partial => "common/outline")

      render "campaigns/options.js.rjs"
    end
  end
  
  describe "cancel campaign options" do
    it "should hide campaign options form" do
      params[:cancel] = "true"
      render "campaigns/options.js.rjs"

      response.should_not have_rjs("options")
      response.should include_text('crm.flip_form("options")')
      response.should include_text('crm.set_title("create_campaign", "Campaigns")')
    end
  end

end


