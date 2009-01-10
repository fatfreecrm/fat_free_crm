require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/new.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    assigns[:current_user] = stub_model(User)
    assigns[:opportunity] = stub_model(Opportunity, :stage => "prospecting", :new_record? => true)
    assigns[:account] = stub_model(Account)
    assigns[:users] = [ stub_model(User) ]
    assigns[:accounts] = [ stub_model(Account) ]
    Setting.stub!(:opportunity_stage).and_return({ :key => "value" })
  end

  it "should render new form" do
    render "/opportunities/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", opportunities_path) do
    end
  end
end


