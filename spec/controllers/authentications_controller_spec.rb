require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthenticationsController do

  # Authentication filters
  #----------------------------------------------------------------------------
  describe "authentication filters" do
    describe "user must not be logged" do
      describe "DELETE authentication (logout form)" do
        it "displays must be logged msg and redirects to login page" do
          delete :destroy
          flash[:notice].should_not == nil
          flash[:notice].should =~ /^You must be logged in/
          response.should redirect_to(login_url)
        end
      end
    end

    describe "user must not be logged" do
      before(:each) do
        @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass")
        @controller.stub!(:current_user).and_return(@user)
      end

      describe "GET authentication (login form)" do
        it "displays must be logged out msg and redirects to profile page" do
          get :new
          flash[:notice].should_not == nil
          flash[:notice].should =~ /^You must be logged out/
          response.should redirect_to(profile_url)
        end
      end

      describe "POST authentication" do
        it "displays must be logged out msg and redirects to profile page" do
          post :create, :authentication => @login
          flash[:notice].should_not == nil
          flash[:notice].should =~ /^You must be logged out/
          response.should redirect_to(profile_url)
        end
      end
    end
  end

  # POST /authentications
  # POST /authentications.xml                                              HTML
  #----------------------------------------------------------------------------
  describe "POST authentications" do
    before(:each) do
      @user = Factory.create(:user, :username => 'test.user')
      @user.stub!(:valid_ldap_credentials?).and_return(true)
      User.stub!(:find_or_create_from_ldap).and_return(@user)
    end
    def do_login
      post :create, :authentication => {:username => 'test.user', :password => "something", :remember_me => "0"}
    end

    describe "successful authentication " do
      it "should use find_or_create_from_ldap to find the user" do
        User.should_receive(:find_or_create_from_ldap).with('test.user').and_return(@user)
        do_login
      end

      it "should create a session upon successfull login" do
        do_login
        session = Authentication.find
        session.should_not be_nil
        session.user.should == @user
      end

      it "displays welcome message and redirects to the home page" do
        @user.update_attributes!(:login_count => 0)
        do_login
        flash[:notice].should_not == nil
        flash[:notice].should_not =~ /last login/
        response.should redirect_to(root_url)
      end

      it "displays last login time if it's not the first login" do
        do_login
        flash[:notice].should =~ /last login/
        response.should redirect_to(root_url)
      end
    end

    describe "invalid password" do
      before :each do
        @user.stub!(:valid_ldap_credentials?).and_return(false)
      end

      it "should not create a session" do
        do_login
        Authentication.find.should be_nil
      end

      it "redirects to login page" do
        do_login
        flash[:warning].should_not == nil
        response.should redirect_to(:action => :new)
      end
    end

    describe "user has been suspended" do
      before :each do
        @user.suspended_at = Date.yesterday
        @user.save!
      end

      it "should not create a session" do
        pending "So it seems that suspending a user never worked."
        do_login
        Authentication.find.should be_nil
      end

      # This tests :before_save update_info callback in Authentication model.
      it "keeps user login attributes intact" do
        @user.update_attributes!(:login_count => 0, :last_login_at => nil, :last_login_ip => nil)
        do_login
        @user.reload
        @user.login_count.should == 0
        @user.last_login_at.should be_nil
        @user.last_login_ip.should be_nil
      end

      it "redirects to login page if user is suspended" do
        do_login
        flash[:warning].should_not == nil # Invalid username/password.
        flash[:notice].should == nil      # Not approved yet.
        response.should redirect_to(:action => :new)
      end

      it "redirects to login page with the message if signup needs approval and user hasn't been activated yet" do
        @user.update_attributes!(:login_count => 0)
        Setting.stub!(:user_signup).and_return(:needs_approval)
        do_login
        flash[:warning].should == nil     # Invalid username/password.
        flash[:notice].should_not == nil  # Not approved yet.
        response.should redirect_to(:action => :new)
      end
    end

    describe "non-existant user" do
      before :each do
        User.stub!(:find_or_create_from_ldap).and_return(nil)
      end

      it "should not create a session" do
        do_login
        Authentication.find.should be_nil
      end

      it "redirects to login page" do
        do_login
        flash[:warning].should_not == nil
        response.should redirect_to(:action => :new)
      end
    end

  end # POST authenticate

end
