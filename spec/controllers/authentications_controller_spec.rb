require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthenticationsController do

  before(:each) do
    activate_authlogic
    logout
  end

  # Authentication filters
  #----------------------------------------------------------------------------
  describe "authentication filters" do
    describe "user must not be logged" do
      describe "DELETE authentication (logout form)" do
        it "displays 'must be logged out message' and redirects to login page" do
          delete :destroy
          flash[:notice].should_not == nil
          flash[:notice].should =~ /^You must be logged in/
          response.should redirect_to(login_path)
        end

        it "redirects to login page" do
          get :show
          response.should redirect_to(login_path)
        end
      end
    end

    describe "user must not be logged in" do
      before(:each) do
        @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass")
        @controller.stub!(:current_user).and_return(@user)
      end

      describe "GET authentication (login form)" do
        it "displays 'must be logged out message' and redirects to profile page" do
          get :new
          flash[:notice].should_not == nil
          flash[:notice].should =~ /^You must be logged out/
          response.should redirect_to(profile_path)
        end
      end

      describe "POST authentication" do
        it "displays 'must be logged out message' and redirects to profile page" do
          post :create, :authentication => @login
          flash[:notice].should_not == nil
          flash[:notice].should =~ /^You must be logged out/
          response.should redirect_to(profile_path)
        end
      end
    end
  end

  # POST /authentications
  # POST /authentications.xml                                              HTML
  #----------------------------------------------------------------------------
  describe "POST authentications" do
    before(:each) do
      @login = { :username => "user", :password => "pass", :remember_me => "0" }
      @authentication = mock(Authentication, @login)
    end

    describe "successful authentication " do
      before(:each) do
        @authentication.stub!(:save).and_return(true)
        Authentication.stub!(:new).and_return(@authentication)
      end

      it "displays welcome message and redirects to the home page" do
        @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass", :login_count => 0)
        @authentication.stub!(:user).and_return(@user)

        post :create, :authentication => @login
        flash[:notice].should_not == nil
        flash[:notice].should_not =~ /last login/
        response.should redirect_to(root_path)
      end

      it "displays last login time if it's not the first login" do
        @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass", :login_count => 42)
        @authentication.stub!(:user).and_return(@user)

        post :create, :authentication => @login
        flash[:notice].should =~ /last login/
        response.should redirect_to(root_path)
      end
    end

    describe "authenticaion failure" do
      describe "user is not suspended" do
        it "redirects to login page if username or password are invalid" do
          @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass")
          @authentication.stub!(:user).and_return(@user)
          @authentication.stub!(:save).and_return(false) # <--- Authentication failure.
          Authentication.stub!(:new).and_return(@authentication)

          post :create, :authentication => @login
          flash[:warning].should_not == nil
          response.should redirect_to(:action => :new)
        end
      end

      describe "user has been suspended" do
        before(:each) do
          @authentication.stub!(:save).and_return(true)
          Authentication.stub!(:new).and_return(@authentication)
        end

        # This tests :before_save update_info callback in Authentication model.
        it "keeps user login attributes intact" do
          @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass", :suspended_at => Date.yesterday, :login_count => 0, :last_login_at => nil, :last_login_ip => nil)
          @authentication.stub!(:user).and_return(@user)

          post :create, :authentication => @login
          @authentication.user.login_count.should == 0
          @authentication.user.last_login_at.should be_nil
          @authentication.user.last_login_ip.should be_nil
        end

        it "redirects to login page if user is suspended" do
          @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass", :suspended_at => Date.yesterday)
          @authentication.stub!(:user).and_return(@user)

          post :create, :authentication => @login
          flash[:warning].should_not == nil # Invalid username/password.
          flash[:notice].should == nil      # Not approved yet.
          response.should redirect_to(:action => :new)
        end

        it "redirects to login page with the message if signup needs approval and user hasn't been activated yet" do
          Setting.stub!(:user_signup).and_return(:needs_approval)
          @user = Factory(:user, :username => "user", :password => "pass", :password_confirmation => "pass", :suspended_at => Date.yesterday, :login_count => 0)
          @authentication.stub!(:user).and_return(@user)

          post :create, :authentication => @login
          flash[:warning].should == nil     # Invalid username/password.
          flash[:notice].should_not == nil  # Not approved yet.
          response.should redirect_to(:action => :new)
        end
      end

    end # authentication failure
  end # POST authenticate

end

