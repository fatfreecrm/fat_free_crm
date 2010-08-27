require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/options.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assigns[:sort_by]  = "opportunities.name ASC"
    assigns[:outline]  = "option_long"
    assign(:per_page, 20)
    assigns[:stage]    = Setting.unroll(:opportunity_stage)
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide [Create Opportunity] form if it's visible" do
    render

    rendered.should include_text('crm.hide_form("create_opportunity")')
  end

  describe "opportunity options" do
    it "should render [options.html.haml] template into :options div and show it" do
      params[:cancel] = nil
      render
    
      rendered.should have_rjs("options") do |rjs|
        with_tag("input[type=hidden]") # @current_user
      end
      rendered.should include_text('crm.flip_form("options")')
      rendered.should include_text('crm.set_title("create_opportunity", "Opportunities Options")')
    end

    it "should call JavaScript functions to load preferences menus" do
      params[:cancel] = nil
      view.should_receive(:render).with(:partial => "common/sort_by")
      view.should_receive(:render).with(:partial => "common/per_page")
      view.should_receive(:render).with(:partial => "common/outline")

      render
    end
  end
  
  describe "cancel opportunity options" do
    it "should hide opportunity options form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("options")
      rendered.should include_text('crm.flip_form("options")')
      rendered.should include_text('crm.set_title("create_opportunity", "Opportunities")')
    end
  end

end


