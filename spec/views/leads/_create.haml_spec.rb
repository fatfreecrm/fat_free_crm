require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_create.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    assigns[:lead] = Factory.build(:lead)
    assigns[:users] = [ @current_user ]
    assigns[:campaign] = @campaign = Factory(:campaign)
    assigns[:campaigns] = [ @campaign ]
  end

  it "should render [create lead] form" do
    view.should_receive(:render).with(hash_including(:partial => "leads/top_section"))
    view.should_receive(:render).with(hash_including(:partial => "leads/status"))
    view.should_receive(:render).with(hash_including(:partial => "leads/contact"))
    view.should_receive(:render).with(hash_including(:partial => "leads/web"))
    view.should_receive(:render).with(hash_including(:partial => "leads/permissions"))

    render "/leads/_create.html.haml"
    rendered.should have_tag("form[class=new_lead]")
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :lead ]

    render "/leads/_create.html.haml"
    rendered.should have_tag("textarea[id=lead_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render "/leads/_create.html.haml"
    rendered.should_not have_tag("textarea[id=lead_background_info]")
  end
end


