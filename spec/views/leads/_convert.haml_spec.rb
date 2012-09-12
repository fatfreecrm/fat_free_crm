require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_convert" do
  include LeadsHelper

  before do
    login_and_assign
    @account = FactoryGirl.create(:account)
    assign(:lead, FactoryGirl.create(:lead))
    assign(:users, [ current_user ])
    assign(:account, @account)
    assign(:accounts, [ @account ])
    assign(:opportunity, FactoryGirl.create(:opportunity))
  end

  it "should render [convert lead] form" do
    render
    view.should render_template(:partial => "leads/_opportunity")
    view.should render_template(:partial => "leads/_convert_permissions")

    rendered.should have_tag("form[class=edit_lead]")
  end

end
