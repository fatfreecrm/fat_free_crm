require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/new.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assign(:opportunity, Opportunity.new(:user => @current_user))
    assign(:users, [ @current_user ])
    assign(:account, @account)
    assign(:accounts, [ @account ])
    assign(:stage, Setting.unroll(:opportunity_stage))
  end
 
  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  it "should hide options form when called from Opportunities index" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render

    rendered.should include('crm.hide_form("options")')
  end

  describe "new opportunity" do
    it "should render [new.html.haml] template into :create_opportunity div" do
      params[:cancel] = nil
      render
    
      rendered.should have_rjs("create_opportunity") do |rjs|
        with_tag("form[class=new_opportunity]")
      end
    end

    it "should call JavaScript functions to load Calendar popup" do
      params[:cancel] = nil
      render

      rendered.should include('crm.flip_form("create_opportunity")')
      rendered.should include('crm.date_select_popup("opportunity_closes_on")')
    end
  end
  
  describe "cancel new opportunity" do
    it "should hide [create campaign] form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("create_opportunity")
      rendered.should include('crm.flip_form("create_opportunity")')
    end
  end

end


