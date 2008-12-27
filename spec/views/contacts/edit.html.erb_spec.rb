require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/edit.html.erb" do
  include ContactsHelper
  
  before(:each) do
    assigns[:contact] = @contact = stub_model(Contact,
      :uuid => "12345678-0123-5678-0123-567890123456",
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/contacts/edit.html.erb"
    
    response.should have_tag("form[action=#{contact_path(@contact)}][method=post]") do
    end
  end
end


