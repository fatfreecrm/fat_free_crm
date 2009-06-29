require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/accounts/update.js.rjs" do
  include AccountsHelper
  
  before(:each) do
    login_and_assign

    assigns[:account] = @account = Factory(:account, :user => @current_user)
    assigns[:users] = [ @current_user ]
  end

  describe "no errors:" do
    describe "on account landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should flip [edit_account] form" do
        render "accounts/update.js.rjs"
        response.should_not have_rjs("account_#{@account.id}")
        response.should include_text('crm.flip_form("edit_account"')
      end

      it "should update sidebar" do
        render "accounts/update.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
          with_tag("div[id=recently]")
        end
        response.should include_text('$("summary").visualEffect("shake"')
      end
    end

    describe "on accounts index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should update sidebar" do
        render "accounts/update.js.rjs"
        response.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
      end
 
      it "should replace [edit_account] form with account partial and highligh it" do
        request.env["HTTP_REFERER"] = "http://localhost/accounts"
        render "accounts/update.js.rjs"
 
        response.should have_rjs("account_#{@account.id}") do |rjs|
          with_tag("li[id=account_#{@account.id}]")
        end
        response.should include_text(%Q/$("account_#{@account.id}").visualEffect("highlight"/)
      end
    end
  end # no errors

  describe "validation errors:" do
    before(:each) do
      @account.errors.add(:error)
    end

    describe "on account landing page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should redraw the [edit_account] form and shake it" do
        render "accounts/update.js.rjs"
 
        response.should have_rjs("edit_account") do |rjs|
          with_tag("form[class=edit_account]")
        end
        response.should include_text('$("edit_account").visualEffect("shake"')
        response.should include_text('focus()')
      end
    end

    describe "on accounts index page -" do
      before(:each) do
        request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should redraw the [edit_account] form and shake it" do
        render "accounts/update.js.rjs"
 
        response.should have_rjs("account_#{@account.id}") do |rjs|
          with_tag("form[class=edit_account]")
        end
        response.should include_text(%Q/$("account_#{@account.id}").visualEffect("shake"/)
        response.should include_text('focus()')
      end
    end
  end # errors
end