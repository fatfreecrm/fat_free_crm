require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/leads/update.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
    assigns[:lead] = @lead = Factory(:lead, :user => @current_user, :assignee => Factory(:user))
    assigns[:users] = [ @current_user ]
    assigns[:campaigns] = [ Factory(:campaign) ]
    assigns[:lead_status_total] = { :contacted => 1, :converted => 1, :new => 1, :rejected => 1, :other => 1, :all => 5 }
  end

  describe "no errors:" do
    describe "on landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should flip [edit_lead] form" do
        render "leads/update.js.rjs"
        response.should_not have_rjs("lead_#{@lead.id}")
        response.should include_text('crm.flip_form("edit_lead"')
      end

      it "should update sidebar" do
        render "leads/update.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
        end
        response.should include_text('$("summary").visualEffect("shake"')
      end
    end

    describe "on index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should replace [Edit Lead] with lead partial and highligh it" do
        render "leads/update.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update sidebar" do
        render "leads/update.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        response.should include_text('$("filters").visualEffect("shake"')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        assigns[:campaign] = Factory(:campaign)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should replace [Edit Lead] with lead partial and highligh it" do
        render "leads/update.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("li[id=lead_#{@lead.id}]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("highlight"/)
      end

      it "should update campaign sidebar" do
        assigns[:campaign] = campaign = Factory(:campaign)
        render "leads/create.js.rjs"

        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[class=panel][id=summary]")
          with_tag("div[class=panel][id=recently]")
        end
      end
    end

  end # no errors

  describe "validation errors :" do
    before(:each) do
      @lead.errors.add(:error)
    end

    describe "on landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render "leads/update.js.rjs"
        response.should have_rjs("edit_lead") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        response.should include_text('$("edit_lead").visualEffect("shake"')
        response.should include_text('focus()')
      end
    end

    describe "on index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/leads"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render "leads/update.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
        response.should include_text('focus()')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
      end

      it "should redraw the [edit_lead] form and shake it" do
        render "leads/update.js.rjs"
        response.should have_rjs("lead_#{@lead.id}") do |rjs|
          with_tag("form[class=edit_lead]")
        end
        response.should include_text(%Q/$("lead_#{@lead.id}").visualEffect("shake"/)
        response.should include_text('focus()')
      end
    end
  end # errors
end