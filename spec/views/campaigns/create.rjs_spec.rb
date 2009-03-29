require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/create.js.rjs" do
  include CampaignsHelper

  before(:each) do
    @current_user = Factory(:user)
    @current_user.stub!(:full_name).and_return("Billy Bones")
    assigns[:current_user] = @current_user
  end

  it "create (success): should hide [Create Campaign] form and insert campaign partial" do
    assigns[:campaign] = Factory(:campaign, :id => 42)
    render "campaigns/create.js.rjs"

    response.should have_rjs(:insert, :top) do |rjs|
      with_tag("li[id=campaign_42]")
    end
    response.should include_text('visualEffect("highlight"')
  end

  it "create (success): should update sidebar filters when called from campaigns page" do
    assigns[:campaign] = Factory(:campaign, :id => 42)
    assigns[:campaign_status_total] = { :called_off => 1, :completed => 1, :on_hold => 1, :planned => 1, :started => 1, :other => 1, :all => 6 }
    request.env["HTTP_REFERER"] = "http://localhost/campaigns"
    render "campaigns/create.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
    end
  end

  it "create (failure): should re-render [create.html.haml] template in :create_campaign div" do
    assigns[:campaign] = Factory.build(:campaign, :name => nil) # make it invalid
    assigns[:users] = [ @current_user ]
  
    render "campaigns/create.js.rjs"
  
    response.should have_rjs("create_campaign") do |rjs|
      with_tag("form[class=new_campaign]")
    end
    response.should include_text('crm.date_select_popup("campaign_starts_on")')
    response.should include_text('crm.date_select_popup("campaign_ends_on")')

  end

end


