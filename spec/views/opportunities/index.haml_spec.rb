require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    login_and_assign
    assigns[:stage] = Setting.unroll(:opportunity_stage)
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assigns[:opportunities] = [ Factory(:opportunity) ].paginate
    template.should_receive(:render).with(hash_including(:partial => "opportunity"))
    template.should_receive(:render).with(:partial => "common/paginate")
    render "/opportunities/index.html.haml"
  end

  it "should render a message if there're no opportunities" do
    assigns[:opportunities] = [].paginate
    template.should_not_receive(:render).with(hash_including(:partial => "opportunities"))
    template.should_receive(:render).with(:partial => "common/empty")
    template.should_receive(:render).with(:partial => "common/paginate")
    render "/opportunities/index.html.haml"
  end

end

