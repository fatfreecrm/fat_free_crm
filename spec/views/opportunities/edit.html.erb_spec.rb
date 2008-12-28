require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/edit.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    assigns[:opportunity] = @opportunity = stub_model(Opportunity,
      :uuid => "12345678-0123-5678-0123-567890123456",
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/opportunities/edit.html.erb"
    
    response.should have_tag("form[action=#{opportunity_path(@opportunity)}][method=post]") do
    end
  end
end


