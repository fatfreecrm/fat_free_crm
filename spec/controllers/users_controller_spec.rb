require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

  before(:each) do
  end

  # GET /users
  # GET /users.xml                              HTML (not directly exposed yet)
  #----------------------------------------------------------------------------
  describe "responding to GET index" do
    before(:each) do
      require_user
    end

    it "should expose all users as @users" do
    end

    describe "with mime type of xml" do
      it "should render all users as xml" do
      end
    end

  end

  # GET /users/1
  # GET /users/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do
    before(:each) do
      require_user
    end

    it "should expose the requested user as @user and render [show] template" do
      @user = Factory(:user)

      get :show, :id => @user.id
      assigns[:user].should == @user
      response.should render_template("users/show")
    end

    it "should expose current user as @user if no specific user was requested" do
      get :show
      assigns[:user].should == @current_user
      response.should render_template("users/show")
    end

    describe "with mime type of xml" do
      before(:each) do
        request.env["HTTP_ACCEPT"] = "application/xml"
      end

      it "should render the requested user as XML" do
        @user = Factory(:user)

        get :show, :id => @user.id
        response.body.should == @user.reload.to_xml
      end

      it "should render current user as XML if no specific user was requested" do
        get :show
        response.body.should == @current_user.to_xml
      end

    end

  end

  # GET /users/new
  # GET /users/new.xml                                                     HTML
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    describe "if user is allowed to sign up" do
      it "should expose a new user as @user and render [new] template" do
        controller.should_receive(:can_signup?).and_return(true)
        @user = Factory.build(:user)
        User.stub!(:new).and_return(@user)

        get :new
        assigns[:user].should == @user
        response.should render_template("users/new")
      end
    end

    describe "if user is not allowed to sign up" do
      it "should redirect to login_path" do
        controller.should_receive(:can_signup?).and_return(false)

        get :new
        response.should redirect_to(login_path)
      end
    end

  end

  # GET /users/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    before(:each) do
      require_user
      @user = @current_user
    end

    it "should expose current user as @user and render [edit] template" do
      xhr :get, :edit, :id => @user.id
      assigns[:user].should == @current_user
      response.should render_template("users/edit")
    end

  end

  # POST /users
  # POST /users.xml                                                        HTML
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do
      before(:each) do
        @username = "none"
        @email = @username + "@example.com"
        @password = "secret"
        @user = Factory.build(:user, :username => @username, :email => @email)
        User.stub!(:new).and_return(@user)
      end

      it "exposes a newly created user as @user and redirect to profile page" do
        post :create, :user => { :username => @username, :email => @email, :password => @password, :password_confirmation => @password }
        assigns[:user].should == @user
        flash[:notice].should =~ /welcome/
        response.should redirect_to(profile_path)
      end

      it "should redirect to login page if user signup needs approval" do
        Setting.stub!(:user_signup).and_return(:needs_approval)

        post :create, :user => { :username => @username, :email => @email, :password => @password, :password_confirmation => @password }
        assigns[:user].should == @user
        flash[:notice].should =~ /approval/
        response.should redirect_to(login_path)
      end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user and renders [new] template" do
        @user = Factory.build(:user, :username => "", :email => "")
        User.stub!(:new).and_return(@user)

        post :create, :user => {}
        assigns[:user].should == @user
        response.should render_template("users/new")
      end
    end

  end

  # PUT /users/1
  # PUT /users/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do
    before(:each) do
      require_user
      @user = @current_user
    end

    describe "with valid params" do

      it "should update user information and render [update] template" do
        xhr :put, :update, :id => @user.id, :user => { :first_name => "Billy", :last_name => "Bones" }
        @user.reload.first_name.should == "Billy"
        @user.last_name.should == "Bones"
        assigns[:user].should == @user
        response.should render_template("users/update")
      end

    end

    describe "with invalid params" do

      it "should not update the user information and redraw [update] template" do
        xhr :put, :update, :id => @user.id, :user => { :first_name => nil }
        @user.reload.first_name.should == @current_user.first_name
        assigns[:user].should == @user
        response.should render_template("users/update")
      end

    end

  end

  # DELETE /users/1
  # DELETE /users/1.xml                HTML and AJAX (not directly exposed yet)
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      require_user
    end

    it "should destroy the requested user" do
    end

    it "should redirect to the users list" do
    end

  end

  # GET /users/1/avatar
  # GET /users/1/avatar.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET avatar" do
    before(:each) do
      require_user
      @user = @current_user
    end

    it "should expose current user as @user and render [avatar] template" do
      xhr :get, :avatar, :id => @user.id
      assigns[:user].should == @current_user
      response.should render_template("users/avatar")
    end
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.xml                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update_avatar" do
    before(:each) do
      require_user
      @user = @current_user
    end

    it "should delete avatar if user chooses to use Gravatar" do
      @avatar = Factory(:avatar, :user => @user, :entity => @user)

      xhr :put, :upload_avatar, :id => @user.id, :gravatar => 1
      @user.avatar.should == nil
      response.should render_template("users/upload_avatar")
    end

    it "should do nothing if user hasn't specified the avatar file to upload" do
      @avatar = Factory(:avatar, :user => @user, :entity => @user)

      xhr :put, :upload_avatar, :id => @user.id, :avatar => nil
      @user.avatar.should == @avatar
      response.should render_template("users/upload_avatar")
    end

    it "should save the user avatar if it was successfully uploaded and resized" do
      @image = fixture_file_upload("spec/fixtures/rails.png", "image/png")

      xhr :put, :upload_avatar, :id => @user.id, :avatar => { :image => @image }
      @user.avatar.should_not == nil
      @user.avatar.image_file_size.should == @image.size
      @user.avatar.image_file_name.should == @image.original_filename
      @user.avatar.image_content_type.should == @image.content_type
      response.should render_template("users/upload_avatar")
    end

# -------------------------- Fix later --------------------------------
#    it "should return errors if the avatar failed to get uploaded and resized" do
#      @image = fixture_file_upload("spec/fixtures/rails.png", "image/png")
#      @user.stub!(:save).and_return(false) # make it fail

#      xhr :put, :upload_avatar, :id => @user.id, :avatar => { :image => @image }
#      @user.avatar.errors.should_not be_empty
#      @user.avatar.should have(1).error # .error_on(:image)
#      response.should render_template("users/upload_avatar")
#    end
  end

  # GET /users/1/password
  # GET /users/1/password.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET avatar" do
    before(:each) do
      require_user
      @user = @current_user
    end

    it "should expose current user as @user and render [pssword] template" do
      xhr :get, :password, :id => @user.id
      assigns[:user].should == @current_user
      response.should render_template("users/password")
    end
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.xml                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT change_password" do
    before(:each) do
      require_user
      @current_user_session.stub!(:unauthorized_record=).and_return(@current_user)
      @current_user_session.stub!(:save).and_return(@current_user)
      @user = @current_user
      @new_password = "secret?!"
    end

    it "should set new user password" do
      xhr :put, :change_password, :id => @user.id, :current_password => @user.password, :user => { :password => @new_password, :password_confirmation => @new_password }
      assigns[:user].should == @current_user
      @current_user.password.should == @new_password
      @current_user.errors.should be_empty
      flash[:notice].should_not == nil
      response.should render_template("users/change_password")
    end

    it "should allow to change password if current password is blank" do
      @user.password_hash = nil
      xhr :put, :change_password, :id => @user.id, :current_password => "", :user => { :password => @new_password, :password_confirmation => @new_password }
      @current_user.password.should == @new_password
      @current_user.errors.should be_empty
      flash[:notice].should_not == nil
      response.should render_template("users/change_password")
    end

    it "should not change user password if password field is blank" do
      xhr :put, :change_password, :id => @user.id, :current_password => @user.password, :user => { :password => "", :password_confirmation => "" }
      assigns[:user].should == @current_user
      @current_user.password.should == @user.password # password stays the same
      @current_user.errors.should be_empty # no errors
      flash[:notice].should_not == nil
      response.should render_template("users/change_password")
    end

    it "should require valid current password" do
      xhr :put, :change_password, :id => @user.id, :current_password => "what?!", :user => { :password => @new_password, :password_confirmation => @new_password }
      @current_user.password.should == @user.password # password stays the same
      @current_user.should have(1).error # .error_on(:current_password)
      response.should render_template("users/change_password")
    end

    it "should require new password and password confirmation to match" do
      xhr :put, :change_password, :id => @user.id, :current_password => @user.password, :user => { :password => @new_password, :password_confirmation => "none" }
      @current_user.password.should == @user.password # password stays the same
      @current_user.should have(1).error # .error_on(:current_password)
      response.should render_template("users/change_password")
    end

  end

end
