require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/new.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assigns[:opportunity] = Opportunity.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end
 
  it "should toggle empty message div if it exists" do
    render "opportunities/new.js.rjs"

    response.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide options form when called from Opportunities index" do
    request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render "opportunities/new.js.rjs"

    response.should include_text('crm.hide_form("options")')
  end

  describe "new opportunity" do
    it "should render [new.html.haml] template into :create_opportunity div" do
      params[:cancel] = nil
      render "opportunities/new.js.rjs"
    
      response.should have_rjs("create_opportunity") do |rjs|
        with_tag("form[class=new_opportunity]")
      end
    end

    it "should call JavaScript functions to load Calendar popup" do
      params[:cancel] = nil
      render "opportunities/new.js.rjs"

      response.should include_text('crm.flip_form("create_opportunity")')
      response.should include_text('crm.date_select_popup("opportunity_closes_on")')
    end
  end
  
  describe "cancel new opportunity" do
    it "should hide [create campaign] form" do
      params[:cancel] = "true"
      render "opportunities/new.js.rjs"

      response.should_not have_rjs("create_opportunity")
      response.should include_text('crm.flip_form("create_opportunity")')
    end
  end

end


