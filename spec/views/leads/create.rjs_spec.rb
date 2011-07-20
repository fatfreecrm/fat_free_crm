require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/create.js.rjs" do
  before do
    login_and_assign
    assign(:campaigns, [ Factory(:campaign) ])
  end

  describe "create success" do
    before do
      assign(:lead, @lead = Factory(:lead))
      assign(:leads, [ @lead ].paginate)
      assign(:lead_status_total, Hash.new(1))
    end

    it "should hide [Create Lead] form and insert lead partial" do
      render

      rendered.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=lead_#{@lead.id}]")
      end
      rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
    end

    it "should update sidebar when called from leads index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      render

      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=filters]")
        with_tag("div[id=recently]")
      end
      rendered.should include('$("filters").visualEffect("shake"')
    end

    it "should update pagination when called from leads index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      render

      rendered.should have_rjs("paginate")
    end

    it "should update related asset sidebar from related asset" do
      assign(:campaign, campaign = Factory(:campaign))
      controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
      render

      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[class=panel][id=summary]")
        with_tag("div[class=panel][id=recently]")
      end
    end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_lead div" do
      assign(:lead, Factory.build(:lead, :first_name => nil)) # make it invalid
      assign(:users, [ Factory(:user) ])

      render

      rendered.should have_rjs("create_lead") do |rjs|
        with_tag("form[class=new_lead]")
      end
      rendered.should include('$("create_lead").visualEffect("shake"')

    end
  end

end


