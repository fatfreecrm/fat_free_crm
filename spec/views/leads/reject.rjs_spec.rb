require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/reject.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead, :status => "new")
    assigns[:lead_status_total] = { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 }
  end

  it "should refresh current lead partial" do
    render "leads/reject.js.rjs"

    response.should have_rjs("lead_#{@lead.id}") do |rjs|
      with_tag("li[id=lead_#{@lead.id}]")
    end
    response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
  end

  it "should update sidebar" do
    render "leads/reject.js.rjs"

    response.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
    end
    response.should include_text('$("filters").visualEffect("shake"')
  end

end