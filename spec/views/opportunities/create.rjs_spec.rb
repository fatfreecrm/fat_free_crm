require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/create.js.rjs" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assigns[:stage] = {}
  end

  it "create (success): should hide [Create Opportunity] form and insert opportunity partial" do
    assigns[:opportunity] = Factory(:opportunity, :id => 42)
    render "opportunities/create.js.rjs"

    response.should have_rjs(:insert, :top) do |rjs|
      with_tag("li[id=opportunity_42]")
    end
    response.should include_text('$("opportunity_42").visualEffect("highlight"')
  end

  it "create (success): should update sidebar filters and recently viewed items when called from opportunities page" do
    assigns[:opportunity] = Factory(:opportunity, :id => 42)
    assigns[:opportunity_stage_total] = {:prospecting=>10, :final_review=>1, :qualification=>1, :won=>2, :all=>20, :analysis=>1, :lost=>0, :presentation=>2, :other=>0, :proposal=>1, :negotiation=>2}
    request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render "opportunities/create.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
      with_tag("div[id=recently]")
    end
  end

  it "create (success): should update recently viewed items when called outside the opportunities (i.e. embedded)" do
    assigns[:opportunity] = Factory(:opportunity, :id => 42)
    assigns[:opportunity_stage_total] = {:prospecting=>10, :final_review=>1, :qualification=>1, :won=>2, :all=>20, :analysis=>1, :lost=>0, :presentation=>2, :other=>0, :proposal=>1, :negotiation=>2}
    request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
    render "opportunities/create.js.rjs"

    response.should have_rjs("recently") do |rjs|
      with_tag("div[class=caption]")
    end
  end

  it "create (failure): should re-render [create.html.haml] template in :create_opportunity div" do
    assigns[:opportunity] = Factory.build(:opportunity, :name => nil) # make it invalid
    @account = Factory(:account)
    assigns[:users] = [ Factory(:user) ]
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  
    render "opportunities/create.js.rjs"
  
    response.should have_rjs("create_opportunity") do |rjs|
      with_tag("form[class=new_opportunity]")
    end
    response.should include_text('$("create_opportunity").visualEffect("shake"')
    response.should include_text("crm.create_or_select_account")
    response.should include_text("crm.date_select_popup")
  end

end


