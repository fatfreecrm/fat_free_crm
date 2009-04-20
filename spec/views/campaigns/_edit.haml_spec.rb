require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/_edit.html.haml" do
  include CampaignsHelper

  before(:each) do
    login_and_assign
    assigns[:campaign] = Factory(:campaign)
    assigns[:users] = [ @current_user ]
  end

  it "should render [edit campaign] form" do
    template.should_receive(:render).with(hash_including(:partial => "campaigns/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "campaigns/objectives"))
    template.should_receive(:render).with(hash_including(:partial => "campaigns/permissions"))
    render "/campaigns/_edit.html.haml"

    response.should have_tag("form[class=edit_campaign]")
  end

end


