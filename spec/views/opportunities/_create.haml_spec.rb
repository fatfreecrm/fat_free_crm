require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/_create.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
  end

  it "should render [create opportunity] form" do
    assigns[:opportunity] = Factory.build(:opportunity)
    template.should_receive(:render).with(hash_including(:partial => "opportunities/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "opportunities/permissions"))

    render "/opportunities/_create.html.haml"
    response.should have_tag("form[class=new_opportunity]")
  end
end


