require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index.js.rjs" do
  include LeadsHelper
  
  before(:each) do
    login_and_assign
  end

  it "should render [lead] template with @leads collection if there are leads" do
    assign(:leads, [ Factory(:lead, :id => 42) ].paginate(:page => 1, :per_page => 20))

    render
    rendered.should have_rjs("leads") do |rjs|
      with_tag("li[id=lead_#{42}]")
    end
    rendered.should have_rjs("paginate")
  end

  it "should render [empty] template if @leads collection if there are no leads" do
    assign(:leads, [].paginate(:page => 1, :per_page => 20))

    render
    rendered.should have_rjs("leads") do |rjs|
      with_tag("div[id=empty]")
    end
    rendered.should have_rjs("paginate")
  end

end