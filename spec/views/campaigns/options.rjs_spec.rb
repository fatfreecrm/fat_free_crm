require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/options.rjs" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assign(:sort_by, "campaigns.name ASC")
    assign(:outline, "option_long")
    assign(:per_page, 20)
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  it "should hide [Create Campaign] form if it's visible" do
    render

    rendered.should include('crm.hide_form("create_campaign")')
  end

  describe "campaign options" do
    it "should render [options.html.haml] template into :options div and show it" do
      params[:cancel] = nil
      render

      rendered.should have_rjs("options") do |rjs|
        with_tag("input[type=hidden]") # @current_user
      end
      rendered.should include('crm.flip_form("options")')
      rendered.should include('crm.set_title("create_campaign", "Campaigns Options")')
    end

    it "should call JavaScript functions to load preferences menus" do
      params[:cancel] = nil

      render
      view.should render_template(:partial => "common/_sort_by")
      view.should render_template(:partial => "common/_per_page")
      view.should render_template(:partial => "common/_outline")
    end
  end

  describe "cancel campaign options" do
    it "should hide campaign options form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("options")
      rendered.should include('crm.flip_form("options")')
      rendered.should include('crm.set_title("create_campaign", "Campaigns")')
    end
  end

end


