require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/destroy.js.rjs" do
  include ContactsHelper

  before(:each) do
    login_and_assign
    assign(:contact, @contact = Factory(:contact))
    assign(:contacts, [ @contact ].paginate)
  end

  it "should blind up destroyed contact partial" do
    render
    rendered.should include(%Q/$("contact_#{@contact.id}").visualEffect("blind_up"/)
  end

  it "should update contacts sidebar when called from contacts index" do
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
    controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    render

    rendered.should have_rjs("recently")
  end

end
