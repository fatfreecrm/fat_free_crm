require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/new.html.erb" do
  include OpportunitiesHelper
  
  before(:each) do
    @current_user = Factory(:user)
    @account = Factory(:account)
    assigns[:opportunity] = Opportunity.new(:user => @current_user)
    assigns[:users] = [ @current_user ]
    assigns[:current_user] = @current_user
    assigns[:account] = @account
    assigns[:accounts] = [ @account ]
  end
 
  it "create: should render [new.html.haml] template into :create_opportunity div" do
    params[:cancel] = nil
    render "opportunities/new.js.rjs"
    
    response.should have_rjs("create_opportunity") do |rjs|
      with_tag("form[class=new_opportunity]")
    end
  end

end


