require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do

  before(:each) do
    require_user(:admin => true)
    set_current_tab(:users)
  end

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  describe "GET index" do
    it "assigns all users as @users and renders [index] template" do
      @users = [ @current_user, Factory(:user) ]

      get :index
      assigns[:users].should == @users
      response.should render_template("admin/users/index")
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  #----------------------------------------------------------------------------
  describe "GET show" do
    it "assigns the requested users as @user and renders [show] template" do
      @user = Factory(:user)

      get :show, :id => @user.id
      assigns[:user].should == @user
      response.should render_template("admin/users/show")
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "GET new" do
    it "assigns a new users as @user and renders [new] template" do
      @user = User.new

      xhr :get, :new
      assigns[:user].attributes.should == @user.attributes
      response.should render_template("admin/users/new")
    end
  end

  # GET /admin/users/1/edit
  #----------------------------------------------------------------------------
  describe "GET edit" do
    it "assigns the requested users as @user and renders [edit] template" do
      @user = Factory(:user)

      get :edit, :id => @user.id
      assigns[:user].should == @user
      response.should render_template("admin/users/edit")
    end
  end

  # POST /admin/users
  # POST /admin/users.xml
  #----------------------------------------------------------------------------
  describe "POST create" do
  
    describe "with valid params" do
      it "assigns a newly created user as @user and redirect to the Admin/Users" do
        username = "none";  email = username + "@example.com"
        @user = Factory.build(:user, :username => username, :email => email)
        User.stub!(:new).and_return(@user)

        post :create, :user => { :username => username, :email => email }
        assigns[:user].should == @user
        response.should redirect_to(admin_users_url)
      end
    end
  
    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user and re-render [new] template" do
        @user = Factory.build(:user, :username => "", :email => "")
        User.stub!(:new).and_return(@user)

        # post :create, :user => {}
        # assigns[:user].should == @user
        # response.should render_template("admin/users/new")
      end
    end
  
  end
  
  # # PUT /admin/users/1
  # # PUT /admin/users/1.xml
  # #----------------------------------------------------------------------------
  describe "PUT update" do
  
    describe "with valid params" do
      it "updates the requested user, assigns it to @user, and redirects to Admin/Users" do
        @user = Factory(:user, :username => "flip", :email => "flip@example.com")

        put :update, :id => @user.id, :user => { :username => "flop", :email => "flop@example.com" }
        assigns[:user].should == @user
        response.should redirect_to(admin_users_url)
      end
    end
  
    describe "with invalid params" do
      it "doesn't update the requested users, but assigns it to @user and redirects to Admin/Users" do
        @user = Factory(:user, :username => "flip", :email => "flip@example.com")

        put :update, :id => @user.id, :user => {}
        assigns[:user].should == @user
        response.should redirect_to(admin_users_url)
      end
    end
  
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml
  #----------------------------------------------------------------------------
  describe "DELETE destroy" do
    it "destroys the requested user" do
      @him = Factory(:user)
      @her = Factory(:user)

      delete :destroy, :id => @him.id
      # lambda { @him.reload }.should raise_error(ActiveRecord::RecordNotFound)
      flash[:notice].should_not == nil
    end

    it "redirects back to the Admin/Users" do
      @user = Factory(:user)

      delete :destroy, :id => @user.id
      response.should redirect_to(admin_users_url)
    end
  end

end
