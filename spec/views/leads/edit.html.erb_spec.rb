require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/edit.html.erb" do
  include LeadsHelper
  
  before(:each) do
    assigns[:lead] = @lead = stub_model(Lead,
      :uuid => "12345678-0123-5678-0123-567890123456",
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/leads/edit.html.erb"
    
    response.should have_tag("form[action=#{lead_path(@lead)}][method=post]") do
    end
  end
end


