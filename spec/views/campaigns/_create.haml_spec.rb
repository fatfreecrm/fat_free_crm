require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/_create.html.haml" do
  include CampaignsHelper
  
  before(:each) do
    @current_user = Factory(:user)
    assigns[:campaign] = Campaign.new
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
  end

  it "should render [create campaign] form" do
    template.should_receive(:render).with(hash_including(:partial => "campaigns/top_section"))
    template.should_receive(:render).with(hash_including(:partial => "campaigns/objectives"))
    template.should_receive(:render).with(hash_including(:partial => "campaigns/permissions"))

    render "/campaigns/_create.html.haml"
    response.should have_tag("form[class=new_campaign]")
  end
end


