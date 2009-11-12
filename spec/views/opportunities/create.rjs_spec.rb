require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/create.js.rjs" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end

  describe "create success" do
    before(:each) do
      assigns[:opportunity] = @opportunity = Factory(:opportunity)
      assigns[:opportunities] = [ @opportunities ].paginate
      assigns[:opportunity_stage_total] = { :prospecting => 10, :final_review => 1, :won => 2, :all => 20, :analysis => 1, :lost => 0, :presentation => 2, :other => 0, :proposal => 1, :negotiation => 2 }
    end

    it "should hide [Create Opportunity] form and insert opportunity partial" do
      render "opportunities/create.js.rjs"

      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=opportunity_#{@opportunity.id}]")
      end
      response.should include_text(%Q/$("opportunity_#{@opportunity.id}").visualEffect("highlight"/)
    end

    it "should update sidebar filters and recently viewed items when called from opportunities page" do
      request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      render "opportunities/create.js.rjs"

      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
    end

    it "should update pagination when called from opportunities index" do
      request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      render "opportunities/create.js.rjs"

      response.should have_rjs("paginate")
    end

    it "should update related campaign sidebar when called from related campaign" do
      assigns[:campaign] = campaign = Factory(:campaign)
      request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
      render "opportunities/create.js.rjs"

      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[class=panel][id=summary]")
        with_tag("div[class=panel][id=recently]")
      end
    end

    it "should update recently viewed items when called from related asset" do
      request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      render "opportunities/create.js.rjs"

      response.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_opportunity div" do
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

end


