require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    assigns[:current_user] = mock_model(User)
    assigns[:users] = [ mock_model(User, :full_name => "Joe Spec") ]
    assigns[:opportunities] = [ stub_model(Opportunity,
      :created_at => Time.now,
      :amount => 100_000,
      :probability => 10,
      :weighted_amount => 10_000,
      :closes_on => Date.yesterday,
      :user => mock_model(User, :full_name => "Joe Spec"),
      :uuid => "12345678-0123-5678-0123-567890123456")
    ]
    Setting.stub!(:opportunity_stage).and_return({ :key => "value" })
    Setting.stub!(:opportunity_stage_color).and_return({ :key => "value" })
  end

  it "should render list of opportunities" do
    render "/opportunities/index.html.erb"
  end
end

