# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AccountsController do
  def get_data_for_sidebar
    @category = Setting.account_category.dup
  end

  before do
    login
    set_current_tab(:accounts)
  end

  # GET /accounts
  # GET /accounts.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do
    before(:each) do
      get_data_for_sidebar
    end

    it "should expose all accounts as @accounts and render [index] template" do
      @accounts = [create(:account, user: current_user)]
      get :index
      expect(assigns[:accounts]).to eq(@accounts)
      expect(response).to render_template("accounts/index")
    end

    it "should collect the data for the accounts sidebar" do
      @accounts = [create(:account, user: current_user)]

      get :index
      expect(assigns[:account_category_total].keys.map(&:to_sym) - (@category << :all << :other)).to eq([])
    end

    it "should filter out accounts by category" do
      categories = %w[customer vendor]
      controller.session[:accounts_filter] = categories.join(',')
      @accounts = [
        create(:account, user: current_user, category: categories.first),
        create(:account, user: current_user, category: categories.last)
      ]
      # This one should be filtered out.
      create(:account, user: current_user, category: "competitor")

      get :index
      expect(assigns[:accounts]).to eq(@accounts)
    end

    it "should perform lookup using query string" do
      @first  = create(:account, user: current_user, name: "The first one")
      @second = create(:account, user: current_user, name: "The second one")

      get :index, params: { query: "second" }
      expect(assigns[:accounts]).to eq([@second])
      expect(assigns[:current_query]).to eq("second")
      expect(session[:accounts_current_query]).to eq("second")
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @accounts = [create(:account, user: current_user)]
        get :index, params: { page: 42 }, xhr: true

        expect(assigns[:current_page].to_i).to eq(42)
        expect(assigns[:accounts]).to eq([]) # page #42 should be empty if there's only one account ;-)
        expect(session[:accounts_current_page].to_i).to eq(42)
        expect(response).to render_template("accounts/index")
      end

      it "should pick up saved page number from session" do
        session[:accounts_current_page] = 42
        @accounts = [create(:account, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(42)
        expect(assigns[:accounts]).to eq([])
        expect(response).to render_template("accounts/index")
      end

      it "should reset current_page when query is altered" do
        session[:accounts_current_page] = 42
        session[:accounts_current_query] = "bill"
        @accounts = [create(:account, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(1)
        expect(assigns[:accounts]).to eq(@accounts)
        expect(response).to render_template("accounts/index")
      end
    end

    describe "with mime type of JSON" do
      it "should render all accounts as json" do
        expect(@controller).to receive(:get_accounts).and_return(accounts = double("Array of Accounts"))
        expect(accounts).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render all accounts as xml" do
        expect(@controller).to receive(:get_accounts).and_return(accounts = double("Array of Accounts"))
        expect(accounts).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        expect(response.body).to eq("generated XML")
      end
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do
    describe "with mime type of HTML" do
      before do
        @account = create(:account, user: current_user)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested account as @account and render [show] template" do
        get :show, params: { id: @account.id }
        expect(assigns[:account]).to eq(@account)
        expect(assigns[:stage]).to eq(@stage)
        expect(assigns[:comment].attributes).to eq(@comment.attributes)
        expect(response).to render_template("accounts/show")
      end

      it "should update an activity when viewing the account" do
        get :show, params: { id: @account.id }
        expect(@account.versions.last.event).to eq('view')
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested account as json" do
        @account = create(:account, user: current_user)
        expect(Account).to receive(:find).and_return(@account)
        expect(@account).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render the requested account as xml" do
        @account = create(:account, user: current_user)
        expect(Account).to receive(:find).and_return(@account)
        expect(@account).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated XML")
      end
    end

    describe "account got deleted or otherwise unavailable" do
      it "should redirect to account index if the account got deleted" do
        @account = create(:account, user: current_user)
        @account.destroy

        get :show, params: { id: @account.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(accounts_path)
      end

      it "should redirect to account index if the account is protected" do
        @private = create(:account, user: create(:user), access: "Private")

        get :show, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(accounts_path)
      end

      it "should return 404 (Not Found) JSON error" do
        @account = create(:account, user: current_user)
        @account.destroy
        request.env["HTTP_ACCEPT"] = "application/json"

        get :show, params: { id: @account.id }
        expect(response.code).to eq("404") # :not_found
      end

      it "should return 404 (Not Found) XML error" do
        @account = create(:account, user: current_user)
        @account.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, params: { id: @account.id }
        expect(response.code).to eq("404") # :not_found
      end
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do
    it "should expose a new account as @account and render [new] template" do
      @account = Account.new(user: current_user,
                             access: Setting.default_access)
      get :new, xhr: true
      expect(assigns[:account].attributes).to eq(@account.attributes)
      expect(assigns[:contact]).to eq(nil)
      expect(response).to render_template("accounts/new")
    end

    it "should created an instance of related object when necessary" do
      @contact = create(:contact, id: 42)

      get :new, params: { related: "contact_42" }, xhr: true
      expect(assigns[:contact]).to eq(@contact)
    end
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose the requested account as @account and render [edit] template" do
      @account = create(:account, id: 42, user: current_user)

      get :edit, params: { id: 42 }, xhr: true
      expect(assigns[:account]).to eq(@account)
      expect(assigns[:previous]).to eq(nil)
      expect(response).to render_template("accounts/edit")
    end

    it "should expose previous account as @previous when necessary" do
      @account = create(:account, id: 42)
      @previous = create(:account, id: 41)

      get :edit, params: { id: 42, previous: 41 }, xhr: true
      expect(assigns[:previous]).to eq(@previous)
    end

    describe "(account got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the account got deleted" do
        @account = create(:account, user: current_user)
        @account.destroy

        get :edit, params: { id: @account.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the account is protected" do
        @private = create(:account, user: create(:user), access: "Private")

        get :edit, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous account got deleted or is otherwise unavailable)" do
      before do
        @account = create(:account, user: current_user)
        @previous = create(:account, user: create(:user))
      end

      it "should notify the view if previous account got deleted" do
        @previous.destroy

        get :edit, params: { id: @account.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("accounts/edit")
      end

      it "should notify the view if previous account got protected" do
        @previous.update_attribute(:access, "Private")

        get :edit, params: { id: @account.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("accounts/edit")
      end
    end
  end

  # POST /accounts
  # POST /accounts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do
    describe "with valid params" do
      it "should expose a newly created account as @account and render [create] template" do
        @account = build(:account, name: "Hello world", user: current_user)
        allow(Account).to receive(:new).and_return(@account)

        post :create, params: { account: { name: "Hello world" } }, xhr: true
        expect(assigns(:account)).to eq(@account)
        expect(response).to render_template("accounts/create")
      end

      # Note: [Create Account] is shown only on Accounts index page.
      it "should reload accounts to update pagination" do
        @account = build(:account, user: current_user)
        allow(Account).to receive(:new).and_return(@account)

        post :create, params: { account: { name: "Hello" } }, xhr: true
        expect(assigns[:accounts]).to eq([@account])
      end

      it "should get data to update account sidebar" do
        @account = build(:account, name: "Hello", user: current_user)
        allow(Campaign).to receive(:new).and_return(@account)

        post :create, params: { account: { name: "Hello" } }, xhr: true
        expect(assigns[:account_category_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should add a new comment to the newly created account when specified" do
        @account = build(:account, name: "Hello world", user: current_user)
        allow(Account).to receive(:new).and_return(@account)

        post :create, params: { account: { name: "Hello world" }, comment_body: "Awesome comment is awesome" }, xhr: true
        expect(assigns[:account].comments.map(&:comment)).to include("Awesome comment is awesome")
      end
    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved account as @account and still render [create] template" do
        @account = build(:account, name: nil, user: nil)
        allow(Account).to receive(:new).and_return(@account)

        post :create, params: { account: {} }, xhr: true
        expect(assigns(:account)).to eq(@account)
        expect(response).to render_template("accounts/create")
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update the requested account, expose the requested account as @account, and render [update] template" do
        @account = create(:account, id: 42, name: "Hello people")

        put :update, params: { id: 42, account: { name: "Hello world" } }, xhr: true
        expect(@account.reload.name).to eq("Hello world")
        expect(assigns(:account)).to eq(@account)
        expect(response).to render_template("accounts/update")
      end

      it "should get data for accounts sidebar when called from Campaigns index" do
        @account = create(:account, id: 42)
        request.env["HTTP_REFERER"] = "http://localhost/accounts"

        put :update, params: { id: 42, account: { name: "Hello" } }, xhr: true
        expect(assigns(:account)).to eq(@account)
        expect(assigns[:account_category_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should update account permissions when sharing with specific users" do
        @account = create(:account, id: 42, access: "Public")

        put :update, params: { id: 42, account: { name: "Hello", access: "Shared", user_ids: [7, 8] } }, xhr: true
        expect(assigns[:account].access).to eq("Shared")
        expect(assigns[:account].user_ids.sort).to eq([7, 8])
      end

      describe "account got deleted or otherwise unavailable" do
        it "should reload current page is the account got deleted" do
          @account = create(:account, user: current_user)
          @account.destroy

          put :update, params: { id: @account.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the account is protected" do
          @private = create(:account, user: create(:user), access: "Private")

          put :update, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "with invalid params" do
      it "should not update the requested account but still expose the requested account as @account, and render [update] template" do
        @account = create(:account, id: 42, name: "Hello people")

        put :update, params: { id: 42, account: { name: nil } }, xhr: true
        expect(assigns(:account).reload.name).to eq("Hello people")
        expect(assigns(:account)).to eq(@account)
        expect(response).to render_template("accounts/update")
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before do
      @account = create(:account, user: current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested account and render [destroy] template" do
        @another_account = create(:account, user: current_user)
        delete :destroy, params: { id: @account.id }, xhr: true

        expect { Account.find(@account.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns[:accounts]).to eq([@another_account]) # @account got deleted
        expect(response).to render_template("accounts/destroy")
      end

      it "should get data for accounts sidebar" do
        delete :destroy, params: { id: @account.id }, xhr: true

        expect(assigns[:account_category_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should try previous page and render index action if current page has no accounts" do
        session[:accounts_current_page] = 42

        delete :destroy, params: { id: @account.id }, xhr: true
        expect(session[:accounts_current_page]).to eq(41)
        expect(response).to render_template("accounts/index")
      end

      it "should render index action when deleting last account" do
        session[:accounts_current_page] = 1

        delete :destroy, params: { id: @account.id }, xhr: true
        expect(session[:accounts_current_page]).to eq(1)
        expect(response).to render_template("accounts/index")
      end

      describe "account got deleted or otherwise unavailable" do
        it "should reload current page is the account got deleted" do
          @account = create(:account, user: current_user)
          @account.destroy

          delete :destroy, params: { id: @account.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the account is protected" do
          @private = create(:account, user: create(:user), access: "Private")

          delete :destroy, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Accounts index when an account gets deleted from its landing page" do
        delete :destroy, params: { id: @account.id }

        expect(flash[:notice]).not_to eq(nil)
        expect(response).to redirect_to(accounts_path)
      end

      it "should redirect to account index with the flash message is the account got deleted" do
        @account = create(:account, user: current_user)
        @account.destroy

        delete :destroy, params: { id: @account.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(accounts_path)
      end

      it "should redirect to account index with the flash message if the account is protected" do
        @private = create(:account, user: create(:user), access: "Private")

        delete :destroy, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(accounts_path)
      end
    end
  end

  # PUT /accounts/1/attach
  # PUT /accounts/1/attach.xml                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = create(:account)
        @attachment = create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end

    describe "contacts" do
      before do
        @model = create(:account)
        @attachment = create(:contact, account: nil)
      end
      it_should_behave_like("attach")
    end
  end

  # POST /accounts/1/discard
  # POST /accounts/1/discard.xml                                           AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST discard" do
    describe "tasks" do
      before do
        @model = create(:account)
        @attachment = create(:task, asset: @model)
      end
      it_should_behave_like("discard")
    end

    describe "contacts" do
      before do
        @attachment = create(:contact)
        @model = create(:account)
        @model.contacts << @attachment
      end
      it_should_behave_like("discard")
    end

    describe "opportunities" do
      before do
        @attachment = create(:opportunity)
        @model = create(:account)
        @model.opportunities << @attachment
      end
      # 'super from singleton method that is defined to multiple classes is not supported;'
      # TODO: Uncomment this when it is fixed in 1.9.3
      # it_should_behave_like("discard")
    end
  end

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before do
      @auto_complete_matches = [create(:account, name: "Hello World", user: current_user)]
    end

    it_should_behave_like("auto complete")
  end

  # GET  /accounts/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET redraw" do
    it "should save user selected account preference" do
      get :redraw, params: { per_page: 42, view: "brief", sort_by: "name" }, xhr: true
      expect(current_user.preference[:accounts_per_page]).to eq(42)
      expect(current_user.preference[:accounts_index_view]).to eq("brief")
      expect(current_user.preference[:accounts_sort_by]).to eq("accounts.name ASC")
    end

    it "should reset current page to 1" do
      get :redraw, params: { per_page: 42, view: "brief", sort_by: "name" }, xhr: true
      expect(session[:accounts_current_page]).to eq(1)
    end

    it "should select @accounts and render [index] template" do
      @accounts = [
        create(:account, name: "A", user: current_user),
        create(:account, name: "B", user: current_user)
      ]

      get :redraw, params: { per_page: 1, sort_by: "name" }, xhr: true
      expect(assigns(:accounts)).to eq([@accounts.first])
      expect(response).to render_template("accounts/index")
    end
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST filter" do
    it "should expose filtered accounts as @accounts and render [index] template" do
      session[:accounts_filter] = "customer,vendor"
      @accounts = [create(:account, category: "partner", user: current_user)]

      post :filter, params: { category: "partner" }, xhr: true
      expect(assigns(:accounts)).to eq(@accounts)
      expect(response).to render_template("accounts/index")
    end

    it "should reset current page to 1" do
      @accounts = []
      post :filter, params: { category: "partner" }, xhr: true

      expect(session[:accounts_current_page]).to eq(1)
    end
  end
end
