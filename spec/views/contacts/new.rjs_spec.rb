require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/new" do
  include ContactsHelper

  before do
    login_and_assign
    @account = FactoryGirl.create(:account)
    assign(:contact, Contact.new(:user => current_user))
    assign(:users, [ current_user ])
    assign(:account, @account)
    assign(:accounts, [ @account ])
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  describe "new contact" do
    it "should render [new] template into :create_contact div" do
      params[:cancel] = nil
      render

      rendered.should have_rjs("create_contact") do |rjs|
        with_tag("form[class=new_contact]")
      end
    end
  end

  describe "cancel new contact" do
    it "should hide [create contact] form" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("create_contact")
      rendered.should include('crm.flip_form("create_contact");')
    end
  end

end
