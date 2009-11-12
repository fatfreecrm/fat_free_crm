require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/create.js.rjs" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
  end

  describe "create success" do
    before(:each) do
      assigns[:campaign] = @campaign = Factory(:campaign)
      assigns[:campaigns] = [ @campaign ].paginate
      assigns[:campaign_status_total] = { :called_off => 1, "Explicit" => 1 }
      render "campaigns/create.js.rjs"
    end

    it "should hide [Create Campaign] form and insert campaign partial" do
      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=campaign_#{@campaign.id}]")
      end
      response.should include_text(%Q/$("campaign_#{@campaign.id}").visualEffect("highlight"/)
    end

    it "should update pagination" do
      response.should have_rjs("paginate")
    end
    
    it "should update Campaigns sidebar filters" do
      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_campaign div" do
      assigns[:campaign] = Factory.build(:campaign, :name => nil) # make it invalid
      assigns[:users] = [ Factory(:user) ]
  
      render "campaigns/create.js.rjs"
  
      response.should have_rjs("create_campaign") do |rjs|
        with_tag("form[class=new_campaign]")
      end
      response.should include_text('$("create_campaign").visualEffect("shake"')
      response.should include_text('crm.date_select_popup("campaign_starts_on")')
      response.should include_text('crm.date_select_popup("campaign_ends_on")')
    end
  end

end


