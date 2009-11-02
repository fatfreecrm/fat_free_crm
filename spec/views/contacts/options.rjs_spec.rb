require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/options.rjs" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
    assigns[:sort_by]  = "contacts.first_name ASC"
    assigns[:outline]  = "option_long"
    assigns[:naming]   = "option_before"
    assigns[:per_page] = 20
  end

  it "should toggle empty message div if it exists" do
    render "contacts/options.js.rjs"

    response.should include_text('crm.flick("empty", "toggle")')
  end

  it "should hide [Create Contact] form if it's visible" do
    render "contacts/options.js.rjs"

    response.should include_text('crm.hide_form("create_contact")')
  end

  describe "contact options" do
    it "should render [options.html.haml] template into :options div and show it" do
      params[:cancel] = nil
      render "contacts/options.js.rjs"
    
      response.should have_rjs("options") do |rjs|
        with_tag("input[type=hidden]") # @current_user
      end
      response.should include_text('crm.flip_form("options")')
      response.should include_text('crm.set_title("create_contact", "Contacts Options")')
    end

    it "should call JavaScript functions to load preferences menus" do
      params[:cancel] = nil
      template.should_receive(:render).with(:partial => "common/sort_by")
      template.should_receive(:render).with(:partial => "common/per_page")
      template.should_receive(:render).with(:partial => "common/outline")
      template.should_receive(:render).with(:partial => "common/naming")

      render "contacts/options.js.rjs"
    end
  end
  
  describe "cancel contact options" do
    it "should hide contact options form" do
      params[:cancel] = "true"
      render "contacts/options.js.rjs"

      response.should_not have_rjs("options")
      response.should include_text('crm.flip_form("options")')
      response.should include_text('crm.set_title("create_contact", "Contacts")')
    end
  end

end
