require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/leads/promote.js.rjs" do
  include LeadsHelper

  before(:each) do
    login_and_assign

    assigns[:users] = [ @current_user ]
    assigns[:account] = @account = Factory(:account)
    assigns[:accounts] = [ @account ]
    assigns[:contact] = Factory(:contact)
    assigns[:opportunity] = Factory(:opportunity)
    assigns[:lead_status_total] = { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 }
  end

  describe "no errors :" do
    before(:each) do
      assigns[:lead] = @lead = Factory(:lead, :status => "converted", :user => @current_user, :assignee => @current_user)
    end

    describe "from lead landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [Convert Lead] form" do
        render "leads/promote.js.rjs"
        response.should_not have_rjs("lead_#{@lead.id}")
        response.should include_text('crm.flip_form("convert_lead"')
      end

      it "should update sidebar" do
        render "leads/promote.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
          with_tag("div[id=recently]")
        end
        response.should include_text('$("summary").visualEffect("shake"')
      end
    end

    describe "from lead index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Convert Lead] with lead partial and highligh it" do
        render "leads/promote.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update sidebar" do
        render "leads/promote.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        response.should include_text('$("filters").visualEffect("shake"')
      end
    end

    describe "from related campaign page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
        assigns[:campaign] = Factory(:campaign)
        assigns[:stage] = Setting.unroll(:opportunity_stage)
        assigns[:opportunity] = @opportunity = Factory(:opportunity)
      end

      it "should replace [Convert Lead] with lead partial and highligh it" do
        render "leads/promote.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update campaign sidebar" do
        render "leads/promote.js.rjs"

        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[class=panel][id=summary]")
          with_tag("div[class=panel][id=recently]")
        end
      end

      it "should insert new opportunity if any" do
        render "leads/promote.js.rjs"

        response.should have_rjs(:insert, :top) do |rjs|
          with_tag("li[id=opportunity_#{@opportunity.id}]")
        end
      end

    end
  end # no errors
  
  describe "validation errors:" do
    before(:each) do
      assigns[:lead] = @lead = Factory(:lead, :status => "new", :user => @current_user, :assignee => @current_user)
    end

    describe "from lead landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render "leads/promote.js.rjs"
        response.should have_rjs("convert_lead") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        response.should include_text(%Q/$("convert_lead").visualEffect("shake"/)
      end
    end

    describe "from lead index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render "leads/promote.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
      end
    end

    describe "from related asset page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [Convert Lead] form and shake it" do
        render "leads/promote.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
      end
    end

    it "should handle new or existing account and set up calendar field" do
      render "leads/promote.js.rjs"
      response.should include_text("crm.create_or_select_account")
      response.should include_text('crm.date_select_popup("opportunity_closes_on")')
      response.should include_text('$("account_name").focus()')
    end
  end # errors
end