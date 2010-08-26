require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assigns[:opportunities] = [ Factory(:opportunity) ].paginate
    view.should_receive(:render).with(hash_including(:partial => "opportunity"))
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

  it "should render a message if there're no opportunities" do
    assigns[:opportunities] = [].paginate
    view.should_not_receive(:render).with(hash_including(:partial => "opportunities"))
    view.should_receive(:render).with(:partial => "common/empty")
    view.should_receive(:render).with(:partial => "common/paginate")
    render
  end

end

