require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/create.js.rjs" do
  before do
    login_and_assign(:admin => true)
  end

  describe "create success" do
    before(:each) do
      assign(:user, @user = Factory(:user))
      assign(:users, [ @user ]) # .paginate
    end

    it "should hide [Create User] form and insert user partial" do
      render

      rendered.should have_rjs(:insert, :top) do |rjs|
        with_tag("li[id=user_#{@user.id}]")
      end
      rendered.should include(%Q/$("user_#{@user.id}").visualEffect("highlight"/)
    end

    # it "should update pagination" do
    #   rendered.should have_rjs("paginate")
    # end
  end

  describe "create failure" do
    it "should re-render [create.html.haml] template in :create_user div" do
      assign(:user, Factory.build(:user, :username => nil)) # make it invalid
      assign(:users, [ @current_user ])
      render

      rendered.should have_rjs("create_user") do |rjs|
        with_tag("form[class=new_user]")
      end
      rendered.should include('$("create_user").visualEffect("shake"')
    end
  end

end
