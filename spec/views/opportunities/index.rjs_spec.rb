require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.js.rjs" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render [opportunity] template with @opportunities collection if there are opportunities" do
    assign(:opportunities, [ Factory(:opportunity, :id => 42) ].paginate)

    render
    rendered.should have_rjs("opportunities") do |rjs|
      with_tag("li[id=opportunity_#{42}]")
    end
    rendered.should have_rjs("paginate")
  end

  it "should render [empty] template if @opportunities collection if there are no opportunities" do
    assign(:opportunities, [].paginate)

    render
    rendered.should have_rjs("opportunities") do |rjs|
      with_tag("div[id=empty]")
    end
    rendered.should have_rjs("paginate")
  end

end
