require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/destroy.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead)
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
  end

  it "should update pagination when called from leads index" do
    assigns[:leads] = [ @lead ].paginate
    request.env["HTTP_REFERER"] = "http://localhost/leads"
    render "leads/destroy.js.rjs"

    response.should have_rjs("paginate")
  end

  it "should update recently viewed items when called from related asset" do
    request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
    render "leads/destroy.js.rjs"

    response.should have_rjs("recently")
  end

end
