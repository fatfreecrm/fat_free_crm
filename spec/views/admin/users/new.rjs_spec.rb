require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/new.js.rjs" do
  before do
    login_and_assign(:admin => true)
    assign(:user, User.new)
  end

  describe "new user" do
    it "shows [create user] form" do
      params[:cancel] = nil
      render
    
      rendered.should have_rjs("create_user") do |rjs|
        with_tag("form[class=new_user]")
      end
    end
  end

  describe "cancel new user" do
    it "hides [create user] form" do
      params[:cancel] = "true"
      render
    
      rendered.should_not have_rjs("create_user")
      rendered.should include('crm.flip_form("create_user");')
    end
  end

end
