require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/campaigns/update.js.rjs" do
  before do
    login_and_assign
    assign(:campaign, @campaign = Factory(:campaign, :user => @current_user))
    assign(:users, [ @current_user ])
    assign(:status, Setting.campaign_status)
    assign(:campaign_status_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should flip [edit_campaign] form" do
        render
        rendered.should_not have_rjs("campaign_#{@campaign.id}")
        rendered.should include('crm.flip_form("edit_campaign"')
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
          with_tag("div[id=recently]")
        end
        rendered.should include('$("summary").visualEffect("shake"')
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      end

      it "should replace [Edit Campaign] with campaign partial and highligh it" do
        render
        rendered.should have_rjs("campaign_#{@campaign.id}") do |rjs|
          with_tag("li[id=campaign_#{@campaign.id}]")
        end
        rendered.should include(%Q/$("campaign_#{@campaign.id}").visualEffect("highlight"/)
      end
    end
  end # no errors

  describe "validation errors:" do
    describe "on landing page -" do
      before do
        @campaign.errors.add(:name)
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_campaign] form and shake it" do
        render
        rendered.should have_rjs("edit_campaign") do |rjs|
          with_tag("form[class=edit_campaign]")
        end
        rendered.should include('crm.date_select_popup("campaign_starts_on")')
        rendered.should include('crm.date_select_popup("campaign_ends_on")')
        rendered.should include('$("edit_campaign").visualEffect("shake"')
        rendered.should include('focus()')
      end
    end

    describe "on index page -" do
      before do
        @campaign.errors.add(:name)
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      end

      it "should redraw the [edit_campaign] form and shake it" do
        render
        rendered.should have_rjs("campaign_#{@campaign.id}") do |rjs|
          with_tag("form[class=edit_campaign]")
        end
        rendered.should include('crm.date_select_popup("campaign_starts_on")')
        rendered.should include('crm.date_select_popup("campaign_ends_on")')
        rendered.should include(%Q/$("campaign_#{@campaign.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
