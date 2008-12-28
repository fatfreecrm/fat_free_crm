require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  before(:each) do
    require_user
    set_current_tab(:accounts)
    @uuid = "12345678-0123-5678-0123-567890123456"
  end
  
  def mock_account(stubs = { :name => "Test Account", :user => mock_model(User) } )
    @mock_account ||= mock_model(Account, stubs)
  end

  describe "responding to GET index" do

    it "should expose all accounts as @accounts" do
      @current_user.should_receive(:owned_and_shared_accounts).and_return([mock_account])
      get :index
      assigns[:accounts].should == [mock_account]
    end

    describe "with mime type of xml" do
  
      it "should render all accounts as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @current_user.should_receive(:owned_and_shared_accounts).and_return(accounts = mock("Array of Accounts"))
        accounts.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do
  
    it "should expose the requested account as @account" do
      Account.should_receive(:find).with(@uuid).and_return(mock_account)
      get :show, :id => @uuid
      assigns[:account].should equal(mock_account)
    end
    
    describe "with mime type of xml" do
  
      it "should render the requested account as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Account.should_receive(:find).with(@uuid).and_return(mock_account)
        mock_account.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => @uuid
        response.body.should == "generated XML"
      end
  
    end
    
  end
  
  describe "responding to GET new" do
  
    it "should expose a new account as @account" do
      mock_users = [ mock_model(User) ]
      Account.should_receive(:new).and_return(mock_account)
      User.should_receive(:all_except).with(@current_user).and_return(mock_users)
      get :new
      assigns[:account].should equal(mock_account)
      assigns[:users].should equal(mock_users)
    end
  
  end
  
  describe "responding to GET edit" do
  
    it "should expose the requested account as @account" do
      Account.should_receive(:find).with(@uuid).and_return(mock_account)
      get :edit, :id => @uuid
      assigns[:account].should equal(mock_account)
    end
  
  end
  
  describe "responding to POST create" do
  
    describe "with valid params" do
      
      it "should expose a newly created account as @account" do
        @account = mock_account(:save => true)
        @users = [ mock_model(User) ]
        Account.should_receive(:new).with({'these' => 'params'}).and_return(@account)
        User.should_receive(:all_except).with(@current_user).and_return(@users)
        @account.should_receive(:save_with_permissions).with(%w(1 2 3)).and_return(true)
        post :create, :account => {:these => 'params'}, :users => %w(1 2 3)
        assigns(:account).should equal(@account)
        assigns(:users).should equal(@users)
      end
  
      it "should redirect to the created account" do
        Account.stub!(:new).and_return(@account = mock_account(:save => true))
        @account.should_receive(:save_with_permissions).with(nil).and_return(true)
        post :create, :account => {}
        response.should redirect_to(account_url(@account))
      end
      
    end
    
    describe "with invalid params" do
  
      it "should expose a newly created but unsaved account as @account" do
        @account = mock_account(:save => false)
        @users = [ mock_model(User) ]
        Account.should_receive(:new).with({'these' => 'params'}).and_return(@account)
        User.should_receive(:all_except).with(@current_user).and_return(@users)
        @account.should_receive(:save_with_permissions).with(%w(1 2 3)).and_return(false)
        post :create, :account => {:these => 'params'}, :users => %w(1 2 3)
        assigns(:account).should equal(@account)
        assigns(:users).should equal(@users)
      end
  
      it "should re-render the 'new' template" do
        Account.stub!(:new).and_return(@account = mock_account(:save => false))
        @account.should_receive(:save_with_permissions).with(nil).and_return(false)
        post :create, :account => {}
        response.should render_template('new')
      end
      
    end
    
  end
  
  describe "responding to PUT udpate" do
  
    describe "with valid params" do
  
      it "should update the requested account" do
        Account.should_receive(:find).with(@uuid).and_return(mock_account)
        mock_account.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @uuid, :account => {:these => 'params'}
      end
  
      it "should expose the requested account as @account" do
        Account.stub!(:find).with(@uuid).and_return(mock_account(:update_attributes => true))
        put :update, :id => @uuid
        assigns(:account).should equal(mock_account)
      end
  
      it "should redirect to the account" do
        Account.stub!(:find).with(@uuid).and_return(mock_account(:update_attributes => true))
        put :update, :id => @uuid
        response.should redirect_to(account_url(mock_account))
      end
  
    end
    
    describe "with invalid params" do
  
      it "should update the requested account" do
        Account.should_receive(:find).with(@uuid).and_return(mock_account)
        mock_account.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @uuid, :account => {:these => 'params'}
      end
  
      it "should expose the account as @account" do
        Account.stub!(:find).with(@uuid).and_return(mock_account(:update_attributes => false))
        put :update, :id => @uuid
        assigns(:account).should equal(mock_account)
      end
  
      it "should re-render the 'edit' template" do
        Account.stub!(:find).with(@uuid).and_return(mock_account(:update_attributes => false))
        put :update, :id => @uuid
        response.should render_template('edit')
      end
  
    end
  
  end
  
  describe "responding to DELETE destroy" do
  
    it "should destroy the requested account" do
      Account.should_receive(:find).with(@uuid).and_return(mock_account)
      mock_account.should_receive(:destroy)
      mock_account.should_receive(:name).and_return("Joe Spec")
      delete :destroy, :id => @uuid
    end
  
    it "should redirect to the accounts list" do
      Account.stub!(:find).with(@uuid).and_return(mock_account(:destroy => true))
      mock_account.should_receive(:name).and_return("Joe Spec")
      delete :destroy, :id => @uuid
      response.should redirect_to(accounts_url)
    end
  
  end

end
