require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/destroy.js.rjs" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assigns[:opportunity] = @opportunity = Factory(:opportunity)
    assigns[:stage] = Setting.unroll(:opportunity_stage)
    assigns[:opportunity_stage_total] = { :prospecting => 1, "Custom" => 1 }
  end

  it "should blind up destroyed opportunity partial" do
    render "opportunities/destroy.js.rjs"
    response.should include_text(%Q/$("opportunity_#{@opportunity.id}").visualEffect("blind_up"/)
  end

  it "should update opportunities sidebar when called from opportunities index" do
    assigns[:opportunities] = [ @opportunity ].paginate
    request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render "opportunities/destroy.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=recently]")
    end
    response.should include_text('$("filters").visualEffect("shake"')
  end

  it "should update pagination when called from opportunities index" do
    assigns[:opportunities] = [ @opportunity ].paginate
    request.env["HTTP_REFERER"] = "http://localhost/opportunities"
    render "opportunities/destroy.js.rjs"

    response.should have_rjs("paginate")
  end

  it "should update related campaign sidebar when called from related campaign" do
    assigns[:campaign] = campaign = Factory(:campaign)
    request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
    render "opportunities/destroy.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[class=panel][id=summary]")
      with_tag("div[class=panel][id=recently]")
    end
  end

  it "should update recently viewed items when called from related asset" do
    request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    render "opportunities/destroy.js.rjs"

    response.should have_rjs("recently")
  end

end
