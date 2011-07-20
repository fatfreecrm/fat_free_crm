require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/update.js.rjs" do
  before do
    login_and_assign
    assign(:lead, @lead = Factory(:lead, :user => @current_user, :assignee => Factory(:user)))
    assign(:users, [ @current_user ])
    assign(:campaigns, [ Factory(:campaign) ])
    assign(:lead_status_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [edit_lead] form" do
        render
        rendered.should_not have_rjs("lead_#{@lead.id}")
        rendered.should include('crm.flip_form("edit_lead"')
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
        end
        rendered.should include('$("summary").visualEffect("shake"')
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Edit Lead] with lead partial and highligh it" do
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

    describe "on related asset page -" do
      before do
        assign(:campaign, Factory(:campaign))
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should replace [Edit Lead] with lead partial and highligh it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update campaign sidebar" do
        assign(:campaign, campaign = Factory(:campaign))
        render

        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[class=panel][id=summary]")
          with_tag("div[class=panel][id=recently]")
        end
      end
    end

  end # no errors

  describe "validation errors :" do
    before do
      @lead.errors.add(:first_name)
    end

    describe "on landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        rendered.should have_rjs("edit_lead") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        rendered.should include('$("edit_lead").visualEffect("shake"')
        rendered.should include('focus()')
      end
    end

    describe "on index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on related asset page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render
        rendered.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        rendered.should include(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
