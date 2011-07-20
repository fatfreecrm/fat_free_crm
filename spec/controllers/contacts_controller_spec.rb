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

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @contacts = [ Factory(:contact, :user => @current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:contacts].should == [] # page #42 should be empty if there's only one contact ;-)
        session[:contacts_current_page].to_i.should == 42
        response.should render_template("contacts/index")
      end

      it "should pick up saved page number from session" do
        session[:contacts_current_page] = 42
        @contacts = [ Factory(:contact, :user => @current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:contacts].should == []
        response.should render_template("contacts/index")
      end
    end

    describe "with mime type of XML" do

      it "should render all contacts as xml" do
        @contacts = [ Factory(:contact, :user => @current_user).reload ]

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.body.should == @contacts.to_xml
      end

    end

  end

  # GET /contacts/1
  # GET /contacts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before(:each) do
        @contact = Factory(:contact, :id => 42)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested contact as @contact" do
        get :show, :id => 42
        assigns[:contact].should == @contact
        assigns[:stage].should == @stage
        assigns[:comment].attributes.should == @comment.attributes
        response.should render_template("contacts/show")
      end

      it "should update an activity when viewing the contact" do
        Activity.should_receive(:log).with(@current_user, @contact, :viewed).once
        get :show, :id => @contact.id
      end
    end

    describe "with mime type of XML" do
      it "should render the requested contact as xml" do
        @contact = Factory(:contact, :id => 42)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @contact.reload.to_xml
      end
    end

    describe "contact got deleted or otherwise unavailable" do
      it "should redirect to contact index if the contact got deleted" do
        @contact = Factory(:contact, :user => @current_user)
        @contact.destroy

        get :show, :id => @contact.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should redirect to contact index if the contact is protected" do
        @private = Factory(:contact, :user => Factory(:user), :access => "Private")

        get :show, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should return 404 (Not Found) XML error" do
        @contact = Factory(:contact, :user => @current_user)
        @contact.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, :id => @contact.id
        response.code.should == "404" # :not_found
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
      @opportunity = Factory(:opportunity)

      xhr :get, :new, :related => "opportunity_#{@opportunity.id}"
      assigns[:opportunity].should == @opportunity
    end

    describe "(when creating related contact)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = Factory(:account)
        @account.destroy

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = Factory(:account, :access => "Private")

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end
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

    describe "(contact got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the contact got deleted" do
        @contact = Factory(:contact, :user => @current_user)
        @contact.destroy

        xhr :get, :edit, :id => @contact.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the contact is protected" do
        @private = Factory(:contact, :user => Factory(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous contact got deleted or is otherwise unavailable)" do
      before(:each) do
        @contact = Factory(:contact, :user => @current_user)
        @previous = Factory(:contact, :user => Factory(:user))
      end

      it "should notify the view if previous contact got deleted" do
        @previous.destroy

        xhr :get, :edit, :id => @contact.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("contacts/edit")
      end

      it "should notify the view if previous contact got protected" do
        @previous.update_attribute(:access, "Private")

        xhr :get, :edit, :id => @contact.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("contacts/edit")
      end
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

      it "should reload contacts to update pagination if called from contacts index" do
        @contact = Factory.build(:contact, :user => @current_user)
        Contact.stub!(:new).and_return(@contact)

        request.env["HTTP_REFERER"] = "http://localhost/contacts"
        xhr :post, :create, :contact => { :first_name => "Billy", :last_name => "Bones" }, :account => {}, :users => %w(1 2 3)
        assigns[:contacts].should == [ @contact ]
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

      describe "contact got deleted or otherwise unavailable" do
        it "should reload current page is the contact got deleted" do
          @contact = Factory(:contact, :user => @current_user)
          @contact.destroy

          xhr :put, :update, :id => @contact.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the contact is protected" do
          @private = Factory(:contact, :user => Factory(:user), :access => "Private")

          xhr :put, :update, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
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
    before(:each) do
      @contact = Factory(:contact, :user => @current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested contact and render [destroy] template" do
        xhr :delete, :destroy, :id => @contact.id

        lambda { Contact.find(@contact) }.should raise_error(ActiveRecord::RecordNotFound)
        response.should render_template("contacts/destroy")
      end

      describe "when called from Contacts index page" do
        before(:each) do
          request.env["HTTP_REFERER"] = "http://localhost/contacts"
        end

        it "should try previous page and render index action if current page has no contacts" do
          session[:contacts_current_page] = 42
          xhr :delete, :destroy, :id => @contact.id

          session[:contacts_current_page].should == 41
          response.should render_template("contacts/index")
        end

        it "should render index action when deleting last contact" do
          session[:contacts_current_page] = 1
          xhr :delete, :destroy, :id => @contact.id

          session[:contacts_current_page].should == 1
          response.should render_template("contacts/index")
        end
      end

      describe "when called from related asset page page" do
        it "should reset current page to 1" do
          request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
          xhr :delete, :destroy, :id => @contact.id

          session[:contacts_current_page].should == 1
          response.should render_template("contacts/destroy")
        end
      end

      describe "contact got deleted or otherwise unavailable" do
        it "should reload current page is the contact got deleted" do
          @contact = Factory(:contact, :user => @current_user)
          @contact.destroy

          xhr :delete, :destroy, :id => @contact.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the contact is protected" do
          @private = Factory(:contact, :user => Factory(:user), :access => "Private")

          xhr :delete, :destroy, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Contacts index when a contact gets deleted from its landing page" do
        delete :destroy, :id => @contact.id

        flash[:notice].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should redirect to contact index with the flash message is the contact got deleted" do
        @contact = Factory(:contact, :user => @current_user)
        @contact.destroy

        delete :destroy, :id => @contact.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should redirect to contact index with the flash message if the contact is protected" do
        @private = Factory(:contact, :user => Factory(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end
    end
  end

  # GET /contacts/search/query                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET search" do
    before(:each) do
      @billy_bones   = Factory(:contact, :user => @current_user, :first_name => "Billy",   :last_name => "Bones")
      @captain_flint = Factory(:contact, :user => @current_user, :first_name => "Captain", :last_name => "Flint")
      @contacts = [ @billy_bones, @captain_flint ]
    end

    it "should perform lookup using query string and redirect to index" do
      xhr :get, :search, :query => "bill"

      assigns[:contacts].should == [ @billy_bones ]
      assigns[:current_query].should == "bill"
      session[:contacts_current_query].should == "bill"
      response.should render_template("index")
    end

    describe "with mime type of XML" do
      it "should perform lookup using query string and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :search, :query => "bill?!"

        response.body.should == [ @billy_bones.reload ].to_xml
      end
    end
  end

  # PUT /contacts/1/attach
  # PUT /contacts/1/attach.xml                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = Factory(:contact)
        @attachment = Factory(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = Factory(:contact)
        @attachment = Factory(:opportunity)
      end
      it_should_behave_like("attach")
    end
  end

  # PUT /contacts/1/attach
  # PUT /contacts/1/attach.xml                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = Factory(:contact)
        @attachment = Factory(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = Factory(:contact)
        @attachment = Factory(:opportunity)
      end
      it_should_behave_like("attach")
    end
  end

  # POST /contacts/1/discard
  # POST /contacts/1/discard.xml                                           AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST discard" do
    describe "tasks" do
      before do
        @model = Factory(:contact)
        @attachment = Factory(:task, :asset => @model)
      end
      it_should_behave_like("discard")
    end

    describe "opportunities" do
      before do
        @attachment = Factory(:opportunity)
        @model = Factory(:contact)
        @model.opportunities << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [ Factory(:contact, :first_name => "Hello", :last_name => "World", :user => @current_user) ]
    end

    it_should_behave_like("auto complete")
  end

  # GET /contacts/options                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    it "should set current user preferences when showing options" do
      @per_page = Factory(:preference, :user => @current_user, :name => "contacts_per_page", :value => Base64.encode64(Marshal.dump(42)))
      @outline  = Factory(:preference, :user => @current_user, :name => "contacts_outline",  :value => Base64.encode64(Marshal.dump("option_long")))
      @sort_by  = Factory(:preference, :user => @current_user, :name => "contacts_sort_by",  :value => Base64.encode64(Marshal.dump("contacts.first_name ASC")))
      @naming   = Factory(:preference, :user => @current_user, :name => "contacts_naming",   :value => Base64.encode64(Marshal.dump("option_after")))

      xhr :get, :options
      assigns[:per_page].should == 42
      assigns[:outline].should  == "option_long"
      assigns[:sort_by].should  == "contacts.first_name ASC"
      assigns[:naming].should   == "option_after"
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, :cancel => "true"
      assigns[:per_page].should == nil
      assigns[:outline].should  == nil
      assigns[:sort_by].should  == nil
      assigns[:naming].should   == nil
    end
  end

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected contact preference" do
      xhr :post, :redraw, :per_page => 42, :outline => "long", :sort_by => "first_name", :naming => "after"
      @current_user.preference[:contacts_per_page].to_i.should == 42
      @current_user.preference[:contacts_outline].should  == "long"
      @current_user.preference[:contacts_sort_by].should  == "contacts.first_name ASC"
      @current_user.preference[:contacts_naming].should   == "after"
    end

    it "should set similar options for Leads" do
      xhr :post, :redraw, :sort_by => "first_name", :naming => "after"
      @current_user.pref[:leads_sort_by].should == "leads.first_name ASC"
      @current_user.pref[:leads_naming].should == "after"
    end

    it "should reset current page to 1" do
      xhr :post, :redraw, :per_page => 42, :outline => "long", :sort_by => "first_name", :naming => "after"
      session[:contacts_current_page].should == 1
    end

    it "should select @contacts and render [index] template" do
      @contacts = [
        Factory(:contact, :first_name => "Alice", :user => @current_user),
        Factory(:contact, :first_name => "Bobby", :user => @current_user)
      ]

      xhr :post, :redraw, :per_page => 1, :sort_by => "first_name"
      assigns(:contacts).should == [ @contacts.first ]
      response.should render_template("contacts/index")
    end
  end

end
