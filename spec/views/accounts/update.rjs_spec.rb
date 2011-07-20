require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/update.js.rjs" do
  include AccountsHelper

  before do
    login_and_assign

    assign(:account, @account = Factory(:account, :user => @current_user))
    assign(:users, [ @current_user ])
    assign(:account_category_total, Hash.new(1))
  end

  describe "no errors:" do
    describe "on account landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should flip [edit_account] form" do
        render
        rendered.should_not have_rjs("account_#{@account.id}")
        rendered.should include('crm.flip_form("edit_account"')
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

    describe "on accounts index page -" do
      before do
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
        rendered.should include(%Q/$("account_#{@account.id}").visualEffect("highlight"/)
      end
    end
  end # no errors

  describe "validation errors:" do
    before do
      @account.errors.add(:name)
    end

    describe "on account landing page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        rendered.should have_rjs("edit_account") do |rjs|
          with_tag("form[class=edit_account]")
        end
        rendered.should include('$("edit_account").visualEffect("shake"')
        rendered.should include('focus()')
      end
    end

    describe "on accounts index page -" do
      before do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts"
      end

      it "should redraw the [edit_account] form and shake it" do
        render

        rendered.should have_rjs("account_#{@account.id}") do |rjs|
          with_tag("form[class=edit_account]")
        end
        rendered.should include(%Q/$("account_#{@account.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end
