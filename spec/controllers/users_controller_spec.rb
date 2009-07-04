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
        response.body.should == @user.to_xml
      end

      it "should render current user as XML if no specific user was requested" do
        get :show
        response.body.should == @current_user.to_xml
      end

    end
    
  end

  # GET /users/new
  # GET /users/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do
  
    it "should expose a new user as @user and render [new] template" do
      @user = Factory.build(:user)
      User.stub!(:new).and_return(@user)

      get :new
      assigns[:user].should == @user
      response.should render_template("users/new")
    end

  end

  # GET /users/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    before(:each) do
      require_user
    end
  
    it "should expose current user as @user and render [edit] template" do
      @user = @current_user

      xhr :get, :edit, :id => @user.id
      assigns[:user].should == @current_user
      response.should render_template("users/edit")
    end

  end

  # POST /users
  # POST /users.xml                                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created user as @user" do
      end

      it "should redirect to the created user" do
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved user as @user" do
      end

      it "should re-render the 'new' template" do
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
    end

    it "should" do
    end
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.xml                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update_avatar" do
    before(:each) do
      require_user
    end

    it "should" do
    end
  end

  # GET /users/1/password
  # GET /users/1/password.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET avatar" do
    before(:each) do
      require_user
    end

    it "should" do
    end
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.xml                                       AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT change_password" do
    before(:each) do
      require_user
    end

    it "should" do
    end
  end

end
