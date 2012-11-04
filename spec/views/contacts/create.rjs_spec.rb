require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/create" do
  include ContactsHelper

  before do
    login_and_assign
  end

  describe "create success" do
    before do
      assign(:contact, @contact = FactoryGirl.create(:contact))
      assign(:contacts, [ @contact ].paginate)
    end

    it "should hide [Create Contact] form and insert contact partial" do
      render

      rendered.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=contact_#{@contact.id}]")
      end
      rendered.should include(%Q/$("contact_#{@contact.id}").visualEffect("highlight"/)
    end

    it "should refresh sidebar when called from contacts index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      render

      rendered.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=recently]")
      end
    end

    it "should update pagination when called from contacts index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      render

      rendered.should have_rjs("paginate")
    end

    it "should update recently viewed items when called from related asset" do
      render

      rendered.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end
  end

  describe "create failure" do
    it "create (failure): should re-render [create] template in :create_contact div" do
      assign(:contact, FactoryGirl.build(:contact, :first_name => nil)) # make it invalid
      @account = FactoryGirl.create(:account)
      assign(:users, [ FactoryGirl.create(:user) ])
      assign(:account, @account)
      assign(:accounts, [ @account ])

      render

      rendered.should have_rjs("create_contact") do |rjs|
        with_tag("form[class=new_contact]")
      end
      rendered.should include('visualEffect("shake"')
    end
  end

end
