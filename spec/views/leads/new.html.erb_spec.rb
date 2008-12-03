require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/new.html.erb" do
  include LeadsHelper
  
  before(:each) do
    assigns[:lead] = stub_model(Lead,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/leads/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", leads_path) do
    end
  end
end


