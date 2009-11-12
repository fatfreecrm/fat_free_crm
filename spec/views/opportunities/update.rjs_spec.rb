require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/opportunities/update.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign

    assigns[:opportunity] = @opportunity = Factory(:opportunity, :user => @current_user, :assignee => Factory(:user))
    assigns[:users] = [ @current_user ]
    assigns[:account] = @account = Factory(:account)
    assigns[:accounts] = [ @account ]
    assigns[:stage] = Setting.unroll(:opportunity_stage)
    assigns[:opportunity_stage_total] = { :prospecting => 1, "Custom" => 1 }
  end

  describe "no errors:" do
    describe "on opportunity landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
      end

      it "should flip [edit_opportunity] form" do
        render "opportunities/update.js.rjs"
        response.should_not have_rjs("opportunity_#{@opportunity.id}")
        response.should include_text('crm.flip_form("edit_opportunity"')
      end

      it "should update sidebar" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
          with_tag("div[id=recently]")
        end
        response.should include_text('$("summary").visualEffect("shake"')
      end
    end

    describe "on opportunities index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should replace [Edit Opportunity] with opportunity partial and highligh it" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("li[id=opportunity_#{@opportunity.id}]")
        end
        response.should include_text(%Q/$("opportunity_#{@opportunity.id}").visualEffect("highlight"/)
      end

      it "should update sidebar" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
        response.should include_text('$("filters").visualEffect("shake"')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should update recently viewed items" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("recently") do |rjs|
          with_tag("div[class=caption]")
        end
      end
 
      it "should replace [Edit Opportunity] with opportunity partial and highligh it" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("li[id=opportunity_#{@opportunity.id}]")
        end
        response.should include_text(%Q/$("opportunity_#{@opportunity.id}").visualEffect("highlight"/)
      end
    end
  end

  describe "validation errors:" do
    before(:each) do
      @opportunity.errors.add(:error)
    end

    describe "on opportunity landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities/123"
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("edit_opportunity") do |rjs|
          with_tag("form[class=edit_opportunity]")
        end
        response.should include_text('crm.create_or_select_account(false)')
        response.should include_text('$("edit_opportunity").visualEffect("shake"')
        response.should include_text('focus()')
      end
    end

    describe "on opportunities index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("form[class=edit_opportunity]")
        end
        response.should include_text('crm.create_or_select_account(false)')
        response.should include_text(%Q/$("opportunity_#{@opportunity.id}").visualEffect("shake"/)
        response.should include_text('focus()')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "should show disabled accounts dropdown when called from accounts landing page" do
        render "opportunities/update.js.rjs"
        response.should include_text("crm.create_or_select_account(#{@referer =~ /\/accounts\//})")
      end

      it "should update related campaign sidebar from campaign landing page" do
        assigns[:campaign] = campaign = Factory(:campaign)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{campaign.id}"
        render "opportunities/create.js.rjs"

        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[class=panel][id=summary]")
          with_tag("div[class=panel][id=recently]")
        end
      end

      it "should redraw the [edit_opportunity] form and shake it" do
        render "opportunities/update.js.rjs"
        response.should have_rjs("opportunity_#{@opportunity.id}") do |rjs|
          with_tag("form[class=edit_opportunity]")
        end
        response.should include_text(%Q/$("opportunity_#{@opportunity.id}").visualEffect("shake"/)
        response.should include_text('focus()')
      end
    end
  end # errors
end