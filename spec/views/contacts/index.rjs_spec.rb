require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index.js.rjs" do
  include ContactsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render [contact] template with @contacts collection if there are contacts" do
    assigns[:contacts] = [ Factory(:contact, :id => 42) ].paginate

    render "/contacts/index.js.rjs"
    response.should have_rjs("contacts") do |rjs|
      with_tag("li[id=contact_#{42}]")
    end
    response.should have_rjs("paginate")
  end

  it "should render [empty] template if @contacts collection if there are no contacts" do
    assigns[:contacts] = [].paginate

    render "/contacts/index.js.rjs"
    response.should have_rjs("contacts") do |rjs|
      with_tag("div[id=empty]")
    end
    response.should have_rjs("paginate")
  end

end