require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.html.haml" do
  include OpportunitiesHelper

  before(:each) do
    login_and_assign
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assign(:opportunities, [ Factory(:opportunity) ].paginate)

    render
    view.should render_template(:partial => "_opportunity")
    view.should render_template(:partial => "common/_paginate")
  end

  it "should render a message if there're no opportunities" do
    assign(:opportunities, [].paginate)

    render
    view.should_not render_template(:partial => "_opportunities")
    view.should render_template(:partial => "common/_empty")
    view.should render_template(:partial => "common/_paginate")
  end

end
