require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  before(:each) do
    require_user
    set_current_tab(:accounts)
  end

  # GET /accounts
  # GET /accounts.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    it "should expose all accounts as @accounts and render [index] template" do
      @accounts = [ Factory(:account, :user => @current_user) ]
      get :index
      assigns[:accounts].should == @accounts
      response.should render_template("accounts/index")
    end

    describe "with mime type of xml" do

      it "should render all accounts as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @accounts = [ Factory(:account, :user => @current_user) ]
        get :index
        response.body.should == @accounts.to_xml
      end

    end

  end

  # GET /accounts/1
  # GET /accounts/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    it "should expose the requested account as @account and render [show] template" do
      @account = Factory(:account, :id => 42)
      @stage = Setting.as_hash(:opportunity_stage)
      @comment = Comment.new

      get :show, :id => 42
      assigns[:account].should == @account
      assigns[:stage].should == @stage
      assigns[:comment].attributes.should == @comment.attributes
      response.should render_template("accounts/show")
    end

    describe "with mime type of xml" do

      it "should render the requested account as xml" do
        @account = Factory(:account, :id => 42)
        @stage = Setting.as_hash(:opportunity_stage)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @account.to_xml
      end

    end

  end

  # GET /accounts/new
  # GET /accounts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new account as @account and render [new] template" do
      @account = Account.new(:user => @current_user)
      @users = [ Factory(:user) ]

      xhr :get, :new
      assigns[:account].attributes.should == @account.attributes
      assigns[:users].should == @users
      assigns[:contact].should == nil
      response.should render_template("accounts/new")
    end

    it "should created an instance of related object when necessary" do
      @contact = Factory(:contact, :id => 42)

      xhr :get, :new, :related => "contact_42"
      assigns[:contact].should == @contact
    end

  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested account as @account and render [edit] template" do
      @account = Factory(:account, :id => 42, :user => @current_user)
      @users = [ Factory(:user) ]

      xhr :get, :edit, :id => 42
      assigns[:account].should == @account
      assigns[:users].should == @users
      assigns[:previous].should == nil
      response.should render_template("accounts/edit")
    end

    it "should expose previous account as @previous when necessary" do
      @account = Factory(:account, :id => 42)
      @previous = Factory(:account, :id => 41)

      xhr :get, :edit, :id => 42, :previous => 41
      assigns[:previous].should == @previous
    end

  end

  # POST /accounts
  # POST /accounts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created account as @account and render [create] template" do
        @account = Factory.build(:account, :name => "Hello world", :user => @current_user)
        Account.stub!(:new).and_return(@account)
        @users = [ Factory(:user) ]

        xhr :post, :create, :account => { :name => "Hello world" }, :users => %w(1 2 3)
        assigns(:account).should == @account
        assigns(:users).should == @users
        response.should render_template("accounts/create")
      end

    end

    describe "with invalid params" do
  
      it "should expose a newly created but unsaved account as @account and still render [create] template" do
        @account = Factory.build(:account, :name => nil, :user => nil)
        Account.stub!(:new).and_return(@account)
        @users = [ Factory(:user) ]

        xhr :post, :create, :account => {}, :users => []
        assigns(:account).should == @account
        assigns(:users).should == @users
        response.should render_template("accounts/create")
      end
    
    end
  
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do
  
    describe "with valid params" do

      it "should update the requested account, expose the requested account as @account, and render [update] template" do
        @account = Factory(:account, :id => 42, :name => "Hello people")

        xhr :put, :update, :id => 42, :account => { :name => "Hello world" }
        @account.reload.name.should == "Hello world"
        assigns(:account).should == @account
        response.should render_template("accounts/update")
      end

      it "should update account permissions when sharing with specific users" do
        @account = Factory(:account, :id => 42, :access => "Public")
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)

        xhr :put, :update, :id => 42, :account => { :name => "Hello", :access => "Shared" }, :users => %w(7 8)
        @account.reload.access.should == "Shared"
        @account.permissions.map(&:user_id).sort.should == [ 7, 8 ]
        assigns[:account].should == @account
      end

    end
  
    describe "with invalid params" do

      it "should not update the requested account but still expose the requested account as @account, and render [update] template" do
        @account = Factory(:account, :id => 42, :name => "Hello people")

        xhr :put, :update, :id => 42, :account => { :name => nil }
        @account.reload.name.should == "Hello people"
        assigns(:account).should == @account
        response.should render_template("accounts/update")
      end

    end

  end
  
  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
  
    it "should destroy the requested account and render [destroy] template" do
      @account = Factory(:account, :id => 42)

      xhr :delete, :destroy, :id => 42
      lambda { @account.reload }.should raise_error(ActiveRecord::RecordNotFound)
      response.should render_template("accounts/destroy")
    end

    it "should redirect to Accounts index when an account gets deleted from its landing page" do
      @account = Factory(:account)

      delete :destroy, :id => @account.id

      flash[:notice].should_not == nil
      response.should redirect_to(accounts_path)
    end

  end

end
