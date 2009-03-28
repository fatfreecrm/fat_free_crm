require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do

  before(:each) do
    require_user
    set_current_tab(:contacts)
  end

  # GET /contacts
  # GET /contacts.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    it "should expose all contacts as @contacts and render [index] template" do
      @contacts = [ Factory(:contact, :user => @current_user) ]

      get :index
      assigns[:contacts].should == @contacts
      response.should render_template("contacts/index")
    end

    describe "with mime type of xml" do

      it "should render all contacts as xml" do
        @contacts = [ Factory(:contact, :user => @current_user) ]

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.body.should == @contacts.to_xml
      end

    end

  end

  # GET /contacts/1
  # GET /contacts/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    it "should expose the requested contact as @contact" do
      @contact = Factory(:contact, :id => 42)
      @stage = Setting.as_hash(:opportunity_stage)
      @comment = Comment.new

      get :show, :id => 42
      assigns[:contact].should == @contact
      assigns[:stage].should == @stage
      assigns[:comment].attributes.should == @comment.attributes
      response.should render_template("contacts/show")
    end

    describe "with mime type of xml" do

      it "should render the requested contact as xml" do
        @contact = Factory(:contact, :id => 42)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @contact.to_xml
      end

    end

  end

  # GET /contacts/new
  # GET /contacts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new contact as @contact and render [new] template" do
      @contact = Contact.new(:user => @current_user)
      @account = Account.new(:user => @current_user)
      @users = [ Factory(:user) ]
      @accounts = [ Factory(:account, :user => @current_user) ]

      xhr :get, :new
      assigns[:contact].attributes.should == @contact.attributes
      assigns[:account].attributes.should == @account.attributes
      assigns[:users].should == @users
      assigns[:accounts].should == @accounts
      assigns[:opportunity].should == nil
      response.should render_template("contacts/new")
    end

    it "should created an instance of related object when necessary" do
      @opportunity = Factory(:opportunity, :id => 42)

      xhr :get, :new, :related => "opportunity_42"
      assigns[:opportunity].should == @opportunity
    end

  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested contact as @contact and render [edit] template" do
      @contact = Factory(:contact, :id => 42, :user => @current_user, :lead => nil)
      @users = [ Factory(:user) ]
      @account = Account.new(:user => @current_user)

      xhr :get, :edit, :id => 42
      assigns[:contact].should == @contact
      assigns[:users].should == @users
      assigns[:account].attributes.should == @account.attributes
      assigns[:previous].should == nil
      response.should render_template("contacts/edit")
    end

    it "should expose the requested contact as @contact and linked account as @account" do
      @account = Factory(:account, :id => 99)
      @contact = Factory(:contact, :id => 42, :user => @current_user, :lead => nil)
      Factory(:account_contact, :account => @account, :contact => @contact)

      xhr :get, :edit, :id => 42
      assigns[:contact].should == @contact
      assigns[:account].should == @account
    end

    it "should expose previous contact as @previous when necessary" do
      @contact = Factory(:contact, :id => 42)
      @previous = Factory(:contact, :id => 1992)

      xhr :get, :edit, :id => 42, :previous => 1992
      assigns[:previous].should == @previous
    end

  end

  # POST /contacts
  # POST /contacts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created contact as @contact and render [create] template" do
        @contact = Factory.build(:contact, :first_name => "Billy", :last_name => "Bones")
        Contact.stub!(:new).and_return(@contact)

        xhr :post, :create, :contact => { :first_name => "Billy", :last_name => "Bones" }, :account => { :name => "Hello world" }, :users => %w(1 2 3)
        assigns(:contact).should == @contact
        assigns(:contact).account.name.should == "Hello world"
        response.should render_template("contacts/create")
      end

      it "should be able to associate newly created contact with the opportunity" do
        @opportunity = Factory(:opportunity, :id => 987);
        @contact = Factory.build(:contact)
        Contact.stub!(:new).and_return(@contact)

        xhr :post, :create, :contact => { :first_name => "Billy"}, :account => {}, :opportunity => 987
        assigns(:contact).opportunities.should include(@opportunity)
        response.should render_template("contacts/create")
      end

    end

    describe "with invalid params" do

      before(:each) do
        @contact = Factory.build(:contact, :first_name => nil, :user => @current_user, :lead => nil)
        Contact.stub!(:new).and_return(@contact)
        @users = [ Factory(:user) ]
      end

      # Redraw [create] form with selected account.
      it "should redraw [Create Contact] form with selected account" do
        @account = Factory(:account, :id => 42, :user => @current_user)

        # This redraws [create] form with blank account.
        xhr :post, :create, :contact => {}, :account => { :id => 42, :user_id => @current_user.id }
        assigns(:contact).should == @contact
        assigns(:users).should == @users
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("contacts/create")
      end

      # Redraw [create] form with related account.
      it "should redraw [Create Contact] form with related account" do
        @account = Factory(:account, :id => 123, :user => @current_user)

        request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
        xhr :post, :create, :contact => { :first_name => nil }, :account => { :name => nil, :user_id => @current_user.id }
        assigns(:contact).should == @contact
        assigns(:users).should == @users
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("contacts/create")
      end

      it "should redraw [Create Contact] form with blank account" do
        @accounts = [ Factory(:account, :user => @current_user) ]
        @account = Account.new(:user => @current_user)

        xhr :post, :create, :contact => { :first_name => nil }, :account => { :name => nil, :user_id => @current_user.id }
        assigns(:contact).should == @contact
        assigns(:users).should == @users
        assigns(:account).attributes.should == @account.attributes
        assigns(:accounts).should == @accounts
        response.should render_template("contacts/create")
      end

      it "should preserve Opportunity when called from Oppotuunity page" do
        @opportunity = Factory(:opportunity, :id => 987);

        xhr :post, :create, :contact => {}, :account => {}, :opportunity => 987
        assigns(:opportunity).should == @opportunity
        response.should render_template("contacts/create")
      end

    end

  end

  # PUT /contacts/1
  # PUT /contacts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested contact and render [update] template" do
        @contact = Factory(:contact, :id => 42, :first_name => "Billy")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Bones" }, :account => {}
        @contact.reload.first_name.should == "Bones"
        assigns(:contact).should == @contact
        response.should render_template("contacts/update")
      end

      it "should be able to create a new account and link it to the contact" do
        @contact = Factory(:contact, :id => 42, :first_name => "Billy")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Bones" }, :account => { :name => "new account" }
        @contact.reload.first_name.should == "Bones"
        @contact.account.name.should == "new account"
      end

      it "should be able to link existing account with the contact" do
        @account = Factory(:account, :id => 99, :name => "Hello world")
        @contact = Factory(:contact, :id => 42, :first_name => "Billy")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Bones" }, :account => { :id => 99 }
        @contact.reload.first_name.should == "Bones"
        @contact.account.id.should == 99
      end

      it "should update contact permissions when sharing with specific users" do
        @contact = Factory(:contact, :id => 42, :access => "Public")
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)

        xhr :put, :update, :id => 42, :contact => { :first_name => "Hello", :access => "Shared" }, :users => %w(7 8), :account => {}
        @contact.reload.access.should == "Shared"
        @contact.permissions.map(&:user_id).sort.should == [ 7, 8 ]
        assigns[:contact].should == @contact
      end

    end

    describe "with invalid params" do

      it "should not update the contact, but still expose it as @contact and render [update] template" do
        @contact = Factory(:contact, :id => 42, :user => @current_user, :first_name => "Billy", :lead => nil)
        @account = Account.new(:user => @current_user)
        @users = [ Factory(:user) ]

        xhr :put, :update, :id => 42, :contact => { :first_name => nil }, :account => {}
        @contact.reload.first_name.should == "Billy"
        assigns(:contact).should == @contact
        assigns(:account).attributes.should == @account.attributes
        assigns(:users).should == @users
        response.should render_template("contacts/update")
      end

      it "should expose existing account as @account if selected" do
        @account = Factory(:account, :id => 99)
        @contact = Factory(:contact, :id => 42, :account => @account)

        xhr :put, :update, :id => 42, :contact => { :first_name => nil }, :account => { :id => 99 }
        assigns(:account).should == @account
      end

    end

  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do

    it "should destroy the requested contact and render [destroy] template" do
      @contact = Factory(:contact, :id => 42)

      xhr :delete, :destroy, :id => 42
      lambda { @contact.reload }.should raise_error(ActiveRecord::RecordNotFound)
      response.should render_template("contacts/destroy")
    end

  end

end
