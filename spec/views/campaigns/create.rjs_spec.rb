require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/create.js.rjs" do
  before do
    login_and_assign
  end

  describe "create success" do
    before do
      assign(:campaign, @campaign = Factory(:campaign))
      assign(:campaigns, [ @campaign ].paginate)
      assign(:campaign_status_total, Hash.new(1))
      render
    end

    it "should hide [Create Campaign] form and insert campaign partial" do
      rendered.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=campaign_#{@campaign.id}]")
      end
      rendered.should include(%Q/$("campaign_#{@campaign.id}").visualEffect("highlight"/)
    end

    it "should update pagination" do
      rendered.should have_rjs("paginate")
    end

    it "should update Campaigns sidebar filters" do
      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_campaign div" do
      assign(:campaign, Factory.build(:campaign, :name => nil)) # make it invalid
      assign(:users, [ Factory(:user) ])

      render

      rendered.should have_rjs("create_campaign") do |rjs|
        with_tag("form[class=new_campaign]")
      end
      rendered.should include('$("create_campaign").visualEffect("shake"')
      rendered.should include('crm.date_select_popup("campaign_starts_on")')
      rendered.should include('crm.date_select_popup("campaign_ends_on")')
    end
  end

end
