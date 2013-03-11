require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ContactsController do

  let(:user) do
    FactoryGirl.create(:user)
  end

  before(:each) do
    @current_user = user
    sign_in(:user, @current_user)
    set_current_tab(:contacts)
  end

  # GET /contacts
  # GET /contacts.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    it "should expose all contacts as @contacts and render [index] template" do
      @contacts = [ FactoryGirl.create(:contact, :user => current_user) ]
      get :index
      assigns[:contacts].count.should == @contacts.count
      assigns[:contacts].should == @contacts
      response.should render_template("contacts/index")
    end

    it "should perform lookup using query string" do
      @billy_bones   = FactoryGirl.create(:contact, :user => current_user, :first_name => "Billy",   :last_name => "Bones")
      @captain_flint = FactoryGirl.create(:contact, :user => current_user, :first_name => "Captain", :last_name => "Flint")

      get :index, :query => "bill"
      assigns[:contacts].should == [ @billy_bones ]
      assigns[:current_query].should == "bill"
      session[:contacts_current_query].should == "bill"
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @contacts = [ FactoryGirl.create(:contact, :user => current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:contacts].should == [] # page #42 should be empty if there's only one contact ;-)
        session[:contacts_current_page].to_i.should == 42
        response.should render_template("contacts/index")
      end

      it "should pick up saved page number from session" do
        session[:contacts_current_page] = 42
        @contacts = [ FactoryGirl.create(:contact, :user => current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:contacts].should == []
        response.should render_template("contacts/index")
      end

      it "should reset current_page when query is altered" do
        session[:contacts_current_page] = 42
        session[:contacts_current_query] = "bill"
        @contacts = [ FactoryGirl.create(:contact, :user => current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 1
        assigns[:contacts].should == @contacts
        response.should render_template("contacts/index")
      end
    end

    describe "with mime type of JSON" do
      it "should render all contacts as JSON" do
        @controller.should_receive(:get_contacts).and_return(contacts = mock("Array of Contacts"))
        contacts.should_receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        response.body.should == "generated JSON"
      end
    end

    describe "with mime type of XML" do
      it "should render all contacts as xml" do
        @controller.should_receive(:get_contacts).and_return(contacts = mock("Array of Contacts"))
        contacts.should_receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.body.should == "generated XML"
      end
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before(:each) do
        @contact = FactoryGirl.create(:contact, :id => 42)
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
        get :show, :id => @contact.id
        @contact.versions.last.event.should == 'view'
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested contact as JSON" do
        @contact = FactoryGirl.create(:contact, :id => 42)
        Contact.should_receive(:find).and_return(@contact)
        @contact.should_receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, :id => 42
        response.body.should == "generated JSON"
      end
    end

    describe "with mime type of XML" do
      it "should render the requested contact as xml" do
        @contact = FactoryGirl.create(:contact, :id => 42)
        Contact.should_receive(:find).and_return(@contact)
        @contact.should_receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == "generated XML"
      end
    end

    describe "contact got deleted or otherwise unavailable" do
      it "should redirect to contact index if the contact got deleted" do
        @contact = FactoryGirl.create(:contact, :user => current_user)
        @contact.destroy

        get :show, :id => @contact.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should redirect to contact index if the contact is protected" do
        @private = FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :access => "Private")

        get :show, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should return 404 (Not Found) XML error" do
        @contact = FactoryGirl.create(:contact, :user => current_user)
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
      @contact = Contact.new(:user => current_user,
                             :access => Setting.default_access)
      @account = Account.new(:user => current_user)
      @accounts = [ FactoryGirl.create(:account, :user => current_user) ]

      xhr :get, :new
      assigns[:contact].attributes.should == @contact.attributes
      assigns[:account].attributes.should == @account.attributes
      assigns[:accounts].should == @accounts
      assigns[:opportunity].should == nil
      response.should render_template("contacts/new")
    end

    it "should created an instance of related object when necessary" do
      @opportunity = FactoryGirl.create(:opportunity)

      xhr :get, :new, :related => "opportunity_#{@opportunity.id}"
      assigns[:opportunity].should == @opportunity
    end

    describe "(when creating related contact)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = FactoryGirl.create(:account)
        @account.destroy

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = FactoryGirl.create(:account, :access => "Private")

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
      @contact = FactoryGirl.create(:contact, :id => 42, :user => current_user, :lead => nil)
      @account = Account.new(:user => current_user)

      xhr :get, :edit, :id => 42
      assigns[:contact].should == @contact
      assigns[:account].attributes.should == @account.attributes
      assigns[:previous].should == nil
      response.should render_template("contacts/edit")
    end

    it "should expose the requested contact as @contact and linked account as @account" do
      @account = FactoryGirl.create(:account, :id => 99)
      @contact = FactoryGirl.create(:contact, :id => 42, :user => current_user, :lead => nil)
      FactoryGirl.create(:account_contact, :account => @account, :contact => @contact)

      xhr :get, :edit, :id => 42
      assigns[:contact].should == @contact
      assigns[:account].should == @account
    end

    it "should expose previous contact as @previous when necessary" do
      @contact = FactoryGirl.create(:contact, :id => 42)
      @previous = FactoryGirl.create(:contact, :id => 1992)

      xhr :get, :edit, :id => 42, :previous => 1992
      assigns[:previous].should == @previous
    end

    describe "(contact got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the contact got deleted" do
        @contact = FactoryGirl.create(:contact, :user => current_user)
        @contact.destroy

        xhr :get, :edit, :id => @contact.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the contact is protected" do
        @private = FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous contact got deleted or is otherwise unavailable)" do
      before(:each) do
        @contact = FactoryGirl.create(:contact, :user => current_user)
        @previous = FactoryGirl.create(:contact, :user => FactoryGirl.create(:user))
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
        @contact = FactoryGirl.build(:contact, :first_name => "Billy", :last_name => "Bones")
        Contact.stub!(:new).and_return(@contact)

        xhr :post, :create, :contact => { :first_name => "Billy", :last_name => "Bones" }, :account => { :name => "Hello world" }
        assigns(:contact).should == @contact
        assigns(:contact).reload.account.name.should == "Hello world"
        response.should render_template("contacts/create")
      end

      it "should be able to associate newly created contact with the opportunity" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 987);
        @contact = FactoryGirl.build(:contact)
        Contact.stub!(:new).and_return(@contact)

        xhr :post, :create, :contact => { :first_name => "Billy"}, :account => {}, :opportunity => 987
        assigns(:contact).opportunities.should include(@opportunity)
        response.should render_template("contacts/create")
      end

      it "should reload contacts to update pagination if called from contacts index" do
        @contact = FactoryGirl.build(:contact, :user => current_user)
        Contact.stub!(:new).and_return(@contact)

        request.env["HTTP_REFERER"] = "http://localhost/contacts"
        xhr :post, :create, :contact => { :first_name => "Billy", :last_name => "Bones" }, :account => {}
        assigns[:contacts].should == [ @contact ]
      end

      it "should add a new comment to the newly created contact when specified" do
        @contact = FactoryGirl.build(:contact, :user => current_user)
        Contact.stub!(:new).and_return(@contact)

        xhr :post, :create, :contact => { :first_name => "Testy", :last_name => "McTest" }, :account => { :name => "Hello world" }, :comment_body => "Awesome comment is awesome"
        assigns[:contact].comments.map(&:comment).should include("Awesome comment is awesome")
      end
    end

    describe "with invalid params" do

      before(:each) do
        @contact = FactoryGirl.build(:contact, :first_name => nil, :user => current_user, :lead => nil)
        Contact.stub!(:new).and_return(@contact)
      end

      # Redraw [create] form with selected account.
      it "should redraw [Create Contact] form with selected account" do
        @account = FactoryGirl.create(:account, :id => 42, :user => current_user)

        # This redraws [create] form with blank account.
        xhr :post, :create, :contact => {}, :account => { :id => 42, :user_id => current_user.id }
        assigns(:contact).should == @contact
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("contacts/create")
      end

      # Redraw [create] form with related account.
      it "should redraw [Create Contact] form with related account" do
        @account = FactoryGirl.create(:account, :id => 123, :user => current_user)

        request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
        xhr :post, :create, :contact => { :first_name => nil }, :account => { :name => nil, :user_id => current_user.id }
        assigns(:contact).should == @contact
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("contacts/create")
      end

      it "should redraw [Create Contact] form with blank account" do
        @accounts = [ FactoryGirl.create(:account, :user => current_user) ]
        @account = Account.new(:user => current_user)

        xhr :post, :create, :contact => { :first_name => nil }, :account => { :name => nil, :user_id => current_user.id }
        assigns(:contact).should == @contact
        assigns(:account).attributes.should == @account.attributes
        assigns(:accounts).should == @accounts
        response.should render_template("contacts/create")
      end

      it "should preserve Opportunity when called from Oppotuunity page" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 987);

        xhr :post, :create, :contact => {}, :account => {}, :opportunity => 987
        assigns(:opportunity).should == @opportunity
        response.should render_template("contacts/create")
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do

    describe "with valid params" do

      it "should update the requested contact and render [update] template" do
        @contact = FactoryGirl.create(:contact, :id => 42, :first_name => "Billy")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Bones" }, :account => {}
        assigns[:contact].first_name.should == "Bones"
        assigns[:contact].should == @contact
        response.should render_template("contacts/update")
      end

      it "should be able to create a new account and link it to the contact" do
        @contact = FactoryGirl.create(:contact, :id => 42, :first_name => "Billy")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Bones" }, :account => { :name => "new account" }
        assigns[:contact].first_name.should == "Bones"
        assigns[:contact].account.name.should == "new account"
      end

      it "should be able to link existing account with the contact" do
        @account = FactoryGirl.create(:account, :id => 99, :name => "Hello world")
        @contact = FactoryGirl.create(:contact, :id => 42, :first_name => "Billy")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Bones" }, :account => { :id => 99 }
        assigns[:contact].first_name.should == "Bones"
        assigns[:contact].account.id.should == 99
      end

      it "should update contact permissions when sharing with specific users" do
        @contact = FactoryGirl.create(:contact, :id => 42, :access => "Public")

        xhr :put, :update, :id => 42, :contact => { :first_name => "Hello", :access => "Shared", :user_ids => [7, 8] }, :account => {}
        assigns[:contact].access.should == "Shared"
        assigns[:contact].user_ids.sort.should == [ 7, 8 ]
        assigns[:contact].should == @contact
      end

      describe "contact got deleted or otherwise unavailable" do
        it "should reload current page is the contact got deleted" do
          @contact = FactoryGirl.create(:contact, :user => current_user)
          @contact.destroy

          xhr :put, :update, :id => @contact.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the contact is protected" do
          @private = FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :access => "Private")

          xhr :put, :update, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end

    end

    describe "with invalid params" do

      it "should not update the contact, but still expose it as @contact and render [update] template" do
        @contact = FactoryGirl.create(:contact, :id => 42, :user => current_user, :first_name => "Billy", :lead => nil)
        @account = Account.new(:user => current_user)

        xhr :put, :update, :id => 42, :contact => { :first_name => nil }, :account => {}
        assigns[:contact].reload.first_name.should == "Billy"
        assigns[:contact].should == @contact
        assigns[:account].attributes.should == @account.attributes
        response.should render_template("contacts/update")
      end

      it "should expose existing account as @account if selected" do
        @account = FactoryGirl.create(:account, :id => 99)
        @contact = FactoryGirl.create(:contact, :id => 42, :account => @account)

        xhr :put, :update, :id => 42, :contact => { :first_name => nil }, :account => { :id => 99 }
        assigns[:account].should == @account
      end

    end

  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      @contact = FactoryGirl.create(:contact, :user => current_user)
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
          @contact = FactoryGirl.create(:contact, :user => current_user)
          @contact.destroy

          xhr :delete, :destroy, :id => @contact.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the contact is protected" do
          @private = FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :access => "Private")

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
        @contact = FactoryGirl.create(:contact, :user => current_user)
        @contact.destroy

        delete :destroy, :id => @contact.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end

      it "should redirect to contact index with the flash message if the contact is protected" do
        @private = FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(contacts_path)
      end
    end
  end

  # PUT /contacts/1/attach
  # PUT /contacts/1/attach.xml                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = FactoryGirl.create(:contact)
        @attachment = FactoryGirl.create(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = FactoryGirl.create(:contact)
        @attachment = FactoryGirl.create(:opportunity)
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
        @model = FactoryGirl.create(:contact)
        @attachment = FactoryGirl.create(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = FactoryGirl.create(:contact)
        @attachment = FactoryGirl.create(:opportunity)
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
        @model = FactoryGirl.create(:contact)
        @attachment = FactoryGirl.create(:task, :asset => @model)
      end
      it_should_behave_like("discard")
    end

    describe "opportunities" do
      before do
        @attachment = FactoryGirl.create(:opportunity)
        @model = FactoryGirl.create(:contact)
        @model.opportunities << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [ FactoryGirl.create(:contact, :first_name => "Hello", :last_name => "World", :user => current_user) ]
    end

    it_should_behave_like("auto complete")
  end

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected contact preference" do
      xhr :post, :redraw, :per_page => 42, :view => "long", :sort_by => "first_name", :naming => "after"
      current_user.preference[:contacts_per_page].to_i.should == 42
      current_user.preference[:contacts_index_view].should  == "long"
      current_user.preference[:contacts_sort_by].should  == "contacts.first_name ASC"
      current_user.preference[:contacts_naming].should   == "after"
    end

    it "should set similar options for Leads" do
      xhr :post, :redraw, :sort_by => "first_name", :naming => "after"
      current_user.pref[:leads_sort_by].should == "leads.first_name ASC"
      current_user.pref[:leads_naming].should == "after"
    end

    it "should reset current page to 1" do
      xhr :post, :redraw, :per_page => 42, :view => "long", :sort_by => "first_name", :naming => "after"
      session[:contacts_current_page].should == 1
    end

    it "should select @contacts and render [index] template" do
      @contacts = [
        FactoryGirl.create(:contact, :first_name => "Alice", :user => current_user),
        FactoryGirl.create(:contact, :first_name => "Bobby", :user => current_user)
      ]

      xhr :post, :redraw, :per_page => 1, :sort_by => "first_name"
      assigns(:contacts).should == [ @contacts.first ]
      response.should render_template("contacts/index")
    end
  end

end
