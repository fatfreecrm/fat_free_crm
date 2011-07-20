require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/promote.js.rjs" do
  before do
    login_and_assign
    assign(:users, [ @current_user ])
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
    assign(:contact, Factory(:contact))
    assign(:opportunity, Factory(:opportunity))
    assign(:lead_status_total, Hash.new(1))
  end

  describe "no errors :" do
    before do
      assign(:lead, @lead = Factory(:lead, :status => "converted", :user => @current_user, :assignee => @current_user))
    end

    describe "from lead landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [Convert Lead] form" do
        render
        rendered.should_not have_rjs("lead_#{@lead.id}")
        rendered.should include('crm.flip_form("convert_lead"')
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

    describe "from lead index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Convert Lead] with lead partial and highligh it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        rendered.should include('$("filters").visualEffect("shake"')
      end
    end

    describe "from related campaign page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
        assign(:campaign, Factory(:campaign))
        assign(:stage, Setting.unroll(:opportunity_stage))
        assign(:opportunity, @opportunity = Factory(:opportunity))
      end

      it "should replace [Convert Lead] with lead partial and highligh it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update campaign sidebar" do
        render

        assert_select_rjs("sidebar") do |rjs|
          with_tag("div[class=panel][id=summary]")
          with_tag("div[class=panel][id=recently]")
        end
      end

      it "should insert new opportunity if any" do
        render

        rendered.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=opportunity_#{@opportunity.id}]")
        end
      end

    end
  end # no errors

  describe "validation errors:" do
    before do
      assign(:lead, @lead = Factory(:lead, :status => "new", :user => @current_user, :assignee => @current_user))
    end

    describe "from lead landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        rendered.should have_rjs("convert_lead") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        rendered.should include(%Q/$("convert_lead").visualEffect("shake"/)
      end
    end

    describe "from lead index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
      end
    end

    describe "from related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
      end
    end

    it "should handle new or existing account and set up calendar field" do
      render
      rendered.should include("crm.create_or_select_account")
      rendered.should include('crm.date_select_popup("opportunity_closes_on")')
      rendered.should include('$("account_name").focus()')
    end
  end # errors
end
