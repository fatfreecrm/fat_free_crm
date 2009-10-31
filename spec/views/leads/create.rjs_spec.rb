require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/create.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:campaigns] = [ Factory(:campaign) ]
  end

  describe "create success" do
    before(:each) do
      assigns[:lead] = @lead = Factory(:lead)
      assigns[:leads] = [ @lead ].paginate
      assigns[:lead_status_total] = { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 }
    end

    it "should hide [Create Lead] form and insert lead partial" do
      render "leads/create.js.rjs"

      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=lead_#{@lead.id}]")
      end
      response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
    end

    it "should update sidebar when called from leads index" do
      request.env["HTTP_REFERER"] = "http://localhost/leads"
      render "leads/create.js.rjs"

      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
      response.should include_text('$("filters").visualEffect("shake"')
    end

    it "should update pagination when called from leads index" do
      request.env["HTTP_REFERER"] = "http://localhost/leads"
      render "leads/create.js.rjs"

      response.should have_rjs("paginate")
    end

    it "should update related asset sidebar from related asset" do
      assigns[:campaign] = campaign = Factory(:campaign)
      request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
      render "leads/create.js.rjs"

      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[class=panel][id=summary]")
        with_tag("div[class=panel][id=recently]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_lead div" do
      assigns[:lead] = Factory.build(:lead, :first_name => nil) # make it invalid
      assigns[:users] = [ Factory(:user) ]
  
      render "leads/create.js.rjs"
  
      response.should have_rjs("create_lead") do |rjs|
        with_tag("form[class=new_lead]")
      end
      response.should include_text('$("create_lead").visualEffect("shake"')

    end
  end

end


