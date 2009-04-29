require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render [lead] template with @leads collection if there are leads" do
    assigns[:leads] = [ Factory(:lead, :id => 42) ].paginate(:page => 1, :per_page => 20)

    render "/leads/index.js.rjs"
    response.should have_rjs("leads") do |rjs|
      with_tag("li[id=lead_#{42}]")
    end
    response.should have_rjs("paginate")
  end

  it "should render [empty] template if @leads collection if there are no leads" do
    assigns[:leads] = [].paginate(:page => 1, :per_page => 20)

    render "/leads/index.js.rjs"
    response.should have_rjs("leads") do |rjs|
      with_tag("div[id=empty]")
    end
    response.should have_rjs("paginate")
  end

end