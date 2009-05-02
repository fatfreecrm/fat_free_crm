require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/create.js.rjs" do
  include ContactsHelper

  before(:each) do
    login_and_assign
  end

  describe "create success" do
    before(:each) do
      assigns[:contact] = @contact = Factory(:contact)
      assigns[:contacts] = [ @contact ].paginate
    end

    it "should hide [Create Contact] form and insert contact partial" do
      render "contacts/create.js.rjs"

      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=contact_#{@contact.id}]")
      end
      response.should include_text(%Q/$("contact_#{@contact.id}").visualEffect("highlight"/)
    end

    it "should refresh sidebar when called from contacts index" do
      request.env["HTTP_REFERER"] = "http://localhost/contacts"
      render "contacts/create.js.rjs"

      response.should have_rjs("sidebar") do |rjs|
        with_tag("div[id=recently]")
      end
    end

    it "should update pagination when called from contacts index" do
      request.env["HTTP_REFERER"] = "http://localhost/contacts"
      render "contacts/create.js.rjs"

      response.should have_rjs("paginate")
    end

    it "should update recently viewed items when called from related asset" do
      render "contacts/create.js.rjs"

      response.should have_rjs("recently") do |rjs|
        with_tag("div[class=caption]")
      end
    end
  end
  
  describe "create failure" do
    it "create (failure): should re-render [create.html.haml] template in :create_contact div" do
      assigns[:contact] = Factory.build(:contact, :first_name => nil) # make it invalid
      @current_user = Factory(:user)
      @account = Factory(:account)
      assigns[:users] = [ @current_user ]
      assigns[:account] = @account
      assigns[:accounts] = [ @account ]

      render "contacts/create.js.rjs"

      response.should have_rjs("create_contact") do |rjs|
        with_tag("form[class=new_contact]")
      end
      response.should include_text('visualEffect("shake"')
    end
  end

end


