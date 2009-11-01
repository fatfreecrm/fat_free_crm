require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/destroy.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead)
    assigns[:lead_status_total] = { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 }
  end

  it "should blind up destroyed lead partial" do
    render "leads/destroy.js.rjs"
    response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("blind_up"/)
  end

  it "should update leads sidebar when called from leads index" do
    assigns[:leads] = [ @lead ].paginate
    request.env["HTTP_REFERER"] = "http://localhost/leads"
    render "leads/destroy.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
    response.should include_text('$("filters").visualEffect("shake"')
  end

  it "should update pagination when called from leads index" do
    assigns[:leads] = [ @lead ].paginate
    request.env["HTTP_REFERER"] = "http://localhost/leads"
    render "leads/destroy.js.rjs"

    response.should have_rjs("paginate")
  end

  it "should update related asset sidebar when called from related asset" do
    assigns[:campaign] = campaign = Factory(:campaign)
    request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render "leads/destroy.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[class=panel][id=summary]")
      with_tag("div[class=panel][id=recently]")
    end
  end

end
