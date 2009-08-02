require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/new.js.rjs" do
  include Admin::UsersHelper

  before(:each) do
    login_and_assign(:admin => true)
    assigns[:user] = User.new
  end

  describe "new user" do
    it "shows [create user] form" do
      params[:cancel] = nil
      render "admin/users/new.js.rjs"
    
      response.should have_rjs("create_user") do |rjs|
        with_tag("form[class=new_user]")
      end
    end
  end

  describe "cancel new user" do
    it "hides [create user] form" do
      params[:cancel] = "true"
      render "admin/users/new.js.rjs"
    
      response.should_not have_rjs("create_user")
      response.should include_text('crm.flip_form("create_user");')
    end
  end

end
