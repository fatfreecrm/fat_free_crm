require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_edit" do
  include LeadsHelper

  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead))
    assign(:users, [ current_user ])
    assign(:campaign, @campaign = FactoryGirl.create(:campaign))
    assign(:campaigns, [ @campaign ])
  end

  it "should render [edit lead] form" do
    render
    view.should render_template(:partial => "leads/_top_section")
    view.should render_template(:partial => "leads/_status")
    view.should render_template(:partial => "leads/_contact")
    view.should render_template(:partial => "leads/_web")
    view.should render_template(:partial => "entities/_permissions")

    rendered.should have_tag("form[class=edit_lead]") do
      with_tag "input[type=hidden][id=lead_user_id][value=#{@lead.user_id}]"
    end
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :lead ]

    render
    rendered.should have_tag("textarea[id=lead_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=lead_background_info]")
  end
end
