require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/new" do
  include LeadsHelper

  before do
    login_and_assign
    @campaign = FactoryGirl.create(:campaign)
    assign(:lead, Lead.new(:user => current_user))
    assign(:users, [ current_user ])
    assign(:campaign, @campaign)
    assign(:campaigns, [ @campaign ])
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  describe "new lead" do
    it "should render [new] template into :create_lead div" do
      params[:cancel] = nil
      render

      rendered.should have_rjs("create_lead") do |rjs|
        with_tag("form[class=new_lead]")
      end
      rendered.should include('crm.flip_form("create_lead")')
    end
  end

  describe "cancel new lead" do
    it "should hide [create_lead] form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("create_lead")
      rendered.should include('crm.flip_form("create_lead");')
    end
  end

end
