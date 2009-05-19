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

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @accounts = [ Factory(:account, :user => @current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:accounts].should == [] # page #42 should be empty if there's only one account ;-)
        session[:accounts_current_page].to_i.should == 42
        response.should render_template("accounts/index")
      end

      it "should pick up saved page number from session" do
        session[:accounts_current_page] = 42
        @accounts = [ Factory(:account, :user => @current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:accounts].should == []
        response.should render_template("accounts/index")
      end
    end

    describe "with mime type of XML" do

      it "should render all accounts as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @accounts = [ Factory(:account, :user => @current_user) ]
        get :index
        response.body.should == @accounts.to_xml
      end

    end

  end

  # GET /accounts/1
  # GET /accounts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before(:each) do
        @account = Factory(:account, :user => @current_user)
        @stage = Setting.as_hash(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested account as @account and render [show] template" do
        get :show, :id => @account.id
        assigns[:account].should == @account
        assigns[:stage].should == @stage
        assigns[:comment].attributes.should == @comment.attributes
        response.should render_template("accounts/show")
      end

      it "should update an activity when viewing the account" do
        Activity.should_receive(:log).with(@current_user, @account, :viewed).once
        get :show, :id => @account.id
      end
    end

    describe "with mime type of XML" do
      it "should render the requested account as xml" do
        @account = Factory(:account, :user => @current_user)
        @stage = Setting.as_hash(:opportunity_stage)
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, :id => @account.id
        response.body.should == @account.to_xml
      end
    end

    describe "account got deleted or otherwise unavailable" do
      it "should redirect to account index if the account got deleted" do
        @account = Factory(:account, :user => @current_user).destroy

        get :show, :id => @account.id
        flash[:warning].should_not == nil
        response.should redirect_to(accounts_path)
      end

      it "should redirect to account index if the account is protected" do
        @private = Factory(:account, :user => Factory(:user), :access => "Private")

        get :show, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(accounts_path)
      end

      it "should return 404 (Not Found) XML error" do
        @account = Factory(:account, :user => @current_user).destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, :id => @account.id
        response.code.should == "404" # :not_found
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

    describe "account got deleted or otherwise unavailable" do
      it "should reload current page with the flash message if the account got deleted" do
        @account = Factory(:account, :user => @current_user).destroy

        xhr :get, :edit, :id => @account.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the account is protected" do
        @private = Factory(:account, :user => Factory(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
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

      # Note: [Create Account] is shown only on Accounts index page.
      it "should reload accounts to update pagination" do
        @account = Factory.build(:account, :user => @current_user)
        Account.stub!(:new).and_return(@account)

        xhr :post, :create, :account => { :name => "Hello" }, :users => %w(1 2 3)
        assigns[:accounts].should == [ @account ]
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

      describe "account got deleted or otherwise unavailable" do
        it "should reload current page is the account got deleted" do
          @account = Factory(:account, :user => @current_user).destroy

          xhr :put, :update, :id => @account.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the account is protected" do
          @private = Factory(:account, :user => Factory(:user), :access => "Private")

          xhr :put, :update, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
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
    before(:each) do
      @account = Factory(:account, :user => @current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested account and render [destroy] template" do
        @another_account = Factory(:account, :user => @current_user)
        xhr :delete, :destroy, :id => @account.id

        lambda { @account.reload }.should raise_error(ActiveRecord::RecordNotFound)
        assigns[:accounts].should == [ @another_account ] # @account got deleted
        response.should render_template("accounts/destroy")
      end

      it "should try previous page and render index action if current page has no accounts" do
        session[:accounts_current_page] = 42

        xhr :delete, :destroy, :id => @account.id
        session[:accounts_current_page].should == 41
        response.should render_template("accounts/index")
      end

      it "should render index action when deleting last account" do
        session[:accounts_current_page] = 1

        xhr :delete, :destroy, :id => @account.id
        session[:accounts_current_page].should == 1
        response.should render_template("accounts/index")
      end

      describe "account got deleted or otherwise unavailable" do
        it "should reload current page is the account got deleted" do
          @account = Factory(:account, :user => @current_user).destroy

          xhr :delete, :destroy, :id => @account.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the account is protected" do
          @private = Factory(:account, :user => Factory(:user), :access => "Private")

          xhr :delete, :destroy, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Accounts index when an account gets deleted from its landing page" do
        delete :destroy, :id => @account.id

        flash[:notice].should_not == nil
        response.should redirect_to(accounts_path)
      end

      it "should redirect to account index with the flash message is the account got deleted" do
        @account = Factory(:account, :user => @current_user).destroy

        delete :destroy, :id => @account.id
        flash[:warning].should_not == nil
        response.should redirect_to(accounts_path)
      end

      it "should redirect to account index with the flash message if the account is protected" do
        @private = Factory(:account, :user => Factory(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(accounts_path)
      end
    end

  end

  # GET /accounts/search/query                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET search" do
    before(:each) do
      @first  = Factory(:account, :user => @current_user, :name => "The first one")
      @second = Factory(:account, :user => @current_user, :name => "The second one")
      @accounts = [ @first, @second ]
    end

    it "should perform lookup using query string and redirect to index" do
      xhr :get, :search, :query => "second"

      assigns[:accounts].should == [ @second ]
      assigns[:current_query].should == "second"
      session[:accounts_current_query].should == "second"
      response.should render_template("index")
    end

    describe "with mime type of XML" do
      it "should perform lookup using query string and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :search, :query => "second?!"

        response.body.should == [ @second ].to_xml
      end
    end
  end

end
