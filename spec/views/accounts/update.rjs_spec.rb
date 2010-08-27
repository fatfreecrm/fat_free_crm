require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/update.js.rjs" do
  include AccountsHelper

  before(:each) do
    login_and_assign

    assign(:account, @account = Factory(:account, :user => @current_user))
    assign(:users, [ @current_user ])
  end

  describe "no errors:" do
    describe "on account landing page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should flip [edit_account] form" do
        render
        rendered.should_not have_rjs("account_#{@account.id}")
        rendered.should match('crm.flip_form("edit_account"')
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=summary]")
          with_tag("div[id=recently]")
        end
        rendered.should match('$("summary").visualEffect("shake"')
      end
    end

    describe "on accounts index page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=filters]")
          with_tag("div[id=recently]")
        end
      end

      it "should replace [edit_account] form with account partial and highligh it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
        render

        rendered.should have_rjs("account_#{@account.id}") do |rjs|
          with_tag("li[id=account_#{@account.id}]")
        end
        rendered.should match(%Q/$("account_#{@account.id}").visualEffect("highlight"/)
      end
    end
  end # no errors

  describe "validation errors:" do
    before(:each) do
      @account.errors.add(:name)
    end

    describe "on account landing page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        rendered.should have_rjs("edit_account") do |rjs|
          with_tag("form[class=edit_account]")
        end
        rendered.should match('$("edit_account").visualEffect("shake"')
        rendered.should match('focus()')
      end
    end

    describe "on accounts index page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        rendered.should have_rjs("account_#{@account.id}") do |rjs|
          with_tag("form[class=edit_account]")
        end
        rendered.should match(%Q/$("account_#{@account.id}").visualEffect("shake"/)
        rendered.should match('focus()')
      end
    end
  end # errors
end
