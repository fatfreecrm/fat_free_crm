require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/_convert.html.haml" do
  include LeadsHelper

  before(:each) do
    login_and_assign
    @account = Factory(:account)
    assign(:lead, Factory(:lead))
    assign(:users, [ @current_user ])
    assign(:account, @account)
    assign(:accounts, [ @account ])
    assign(:opportunity, Factory(:opportunity))
  end

  it "should render [convert lead] form" do
    render
    view.should render_template(:partial => "leads/_opportunity")
    view.should render_template(:partial => "leads/_convert_permissions")

    rendered.should have_tag("form[class=edit_lead]")
  end

end
