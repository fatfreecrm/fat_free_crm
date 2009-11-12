require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_create.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assigns[:opportunity] = Factory.build(:opportunity)
    @account = Factory(:account)
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
    assigns[:users] = [ @current_user ]
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end

  it "should render [create opportunity] form" do
    template.should_receive(:render).with(hash_including(:partial => "opportunities/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "opportunities/permissions"))

    render "/opportunities/_create.html.haml"
    response.should have_tag("form[class=new_opportunity]")
  end

  it "should pick default assignee (Myself)" do
    render "/opportunities/_create.html.haml"
    response.should have_tag("select[id=opportunity_assigned_to]") do |options|
      options.to_s.should_not include_text(%Q/selected="selected"/)
    end
  end
end


