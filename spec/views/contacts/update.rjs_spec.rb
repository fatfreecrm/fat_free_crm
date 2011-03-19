require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/update.js.rjs" do
  include ContactsHelper

  before(:each) do
    login_and_assign

    assign(:contact, @contact = Factory(:contact, :user => @current_user))
    assign(:users, [ @current_user ])
    assign(:account, @account = Factory(:account))
    assign(:accounts, [ @account ])
  end

  describe "no errors:" do
    describe "on contact landing page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
      end

      it "should flip [edit_contact] form" do
        render
        rendered.should_not have_rjs("contact_#{@contact.id}")
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

    describe "on contacts index page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      end

      it "should replace [Edit Contact] with contact partial and highligh it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"

        render
        rendered.should have_rjs("contact_#{@contact.id}") do |rjs|
          with_tag("li[id=contact_#{@contact.id}]")
        end
        rendered.should include(%Q/$("contact_#{@contact.id}").visualEffect("highlight"/)
      end

      it "should update sidebar" do
        render
        rendered.should have_rjs("sidebar") do |rjs|
          with_tag("div[id=recently]")
        end
      end
    end

    describe "on related asset page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
      end

      it "should replace [Edit Contact] with contact partial and highligh it" do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"

        render
        rendered.should have_rjs("contact_#{@contact.id}") do |rjs|
          with_tag("li[id=contact_#{@contact.id}]")
        end
        rendered.should include(%Q/$("contact_#{@contact.id}").visualEffect("highlight"/)
      end

      it "should update recently viewed items" do
        render
        rendered.should have_rjs("recently") do |rjs|
          with_tag("div[class=caption]")
        end
      end
    end
  end # no errors

  describe "validation errors:" do
    before(:each) do
      @contact.errors.add(:first_name)
    end

    describe "on contact landing page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts/123"
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        rendered.should have_rjs("edit_contact") do |rjs|
          with_tag("form[class=edit_contact]")
        end
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include('$("edit_contact").visualEffect("shake"')
        rendered.should include('focus()')
      end
    end

    describe "on contacts index page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        rendered.should have_rjs("contact_#{@contact.id}") do |rjs|
          with_tag("form[class=edit_contact]")
        end
        rendered.should include('crm.create_or_select_account(false)')
        rendered.should include(%Q/$("contact_#{@contact.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end

    describe "on related asset page -" do
      before(:each) do
        controller.request.env["HTTP_REFERER"] = @referer = "http://localhost/accounts/123"
      end

      it "errors: should show disabled accounts dropdown" do
        render
        rendered.should include("crm.create_or_select_account(#{@referer =~ /\/accounts\//})")
      end

      it "should redraw the [edit_contact] form and shake it" do
        render
        rendered.should have_rjs("contact_#{@contact.id}") do |rjs|
          with_tag("form[class=edit_contact]")
        end
        rendered.should include(%Q/$("contact_#{@contact.id}").visualEffect("shake"/)
        rendered.should include('focus()')
      end
    end
  end # errors
end

