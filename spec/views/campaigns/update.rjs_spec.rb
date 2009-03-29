require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/campaigns/update.js.rjs" do
  include CampaignsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @current_user.stub!(:full_name).and_return("Billy Bones")
    @campaign = Factory(:campaign, :id => 42, :user => @current_user)
    assigns[:campaign] = @campaign
    assigns[:current_user] = @current_user
    assigns[:users] = [ @current_user ]
    assigns[:status] = Setting.as_hash(:campaign_status)
    assigns[:campaign_status_total] = { :called_off => 1, :completed => 1, :on_hold => 1, :planned => 1, :started => 1, :other => 1, :all => 6 }
  end
 
  it "no errors: should flip [edit_campaign] form when called from campaign landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
  
    render "campaigns/update.js.rjs"
    response.should_not have_rjs("campaign_42")
    response.should include_text('crm.flip_form("edit_campaign"')
  end
  
  it "no errors: should update sidebar when called from campaign landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
  
    render "campaigns/update.js.rjs"
    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=summary]")
    end
    response.should include_text('visualEffect("shake"')
  end
   
  it "no errors: should replace [Edit Campaign] with campaign partial and highligh it when called outside campaign landing page" do
    request.env["HTTP_REFERER"] = "http://localhost/campaigns"
  
    render "campaigns/update.js.rjs"
    response.should have_rjs("campaign_42") do |rjs|
      with_tag("li[id=campaign_42]")
    end
    response.should include_text('visualEffect("highlight"')
  end
   
  it "errors: should redraw the [edit_campaign] form and shake it" do
    @campaign.errors.add(:error)
  
    render "campaigns/update.js.rjs"
    response.should have_rjs("campaign_42") do |rjs|
      with_tag("form[class=edit_campaign]")
    end
    response.should include_text('crm.date_select_popup("campaign_starts_on")')
    response.should include_text('crm.date_select_popup("campaign_ends_on")')
    response.should include_text('visualEffect("shake"')
    response.should include_text('focus()')
  end

end