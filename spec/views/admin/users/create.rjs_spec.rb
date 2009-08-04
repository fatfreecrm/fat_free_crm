require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/create.js.rjs" do
  include Admin::UsersHelper

  before(:each) do
    login_and_assign(:admin => true)
  end

  describe "create success" do
    before(:each) do
      assigns[:user] = @user = Factory(:user)
      assigns[:users] = [ @user ] # .paginate
    end

    it "should hide [Create User] form and insert user partial" do
      render

      response.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=user_#{@user.id}]")
      end
      response.should include_text(%Q/$("user_#{@user.id}").visualEffect("highlight"/)
    end

    # it "should update pagination" do
    #   response.should have_rjs("paginate")
    # end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_user div" do
      assigns[:user] = Factory.build(:user, :username => nil) # make it invalid
      assigns[:users] = [ @current_user ]
      render

      response.should have_rjs("create_user") do |rjs|
        with_tag("form[class=new_user]")
      end
      response.should include_text('$("create_user").visualEffect("shake"')
    end
  end

end


