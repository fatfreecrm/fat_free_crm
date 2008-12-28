require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/new.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    assigns[:opportunity] = stub_model(Opportunity,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/opportunities/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", opportunities_path) do
    end
  end
end


