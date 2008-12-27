require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/edit.html.erb" do
  include AccountsHelper
  
  before(:each) do
    assigns[:account] = @account = stub_model(Account,
      :uuid => "12345678-0123-5678-0123-567890123456",
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/accounts/edit.html.erb"
    
    response.should have_tag("form[action=#{account_path(@account)}][method=post]") do
    end
  end
end


