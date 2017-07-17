# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
      @contacts = [FactoryGirl.create(:contact, user: current_user)]
      get :index
      expect(assigns[:contacts].count).to eq(@contacts.count)
      expect(assigns[:contacts]).to eq(@contacts)
      expect(response).to render_template("contacts/index")
    end

    it "should perform lookup using query string" do
      @billy_bones   = FactoryGirl.create(:contact, user: current_user, first_name: "Billy",   last_name: "Bones")
      @captain_flint = FactoryGirl.create(:contact, user: current_user, first_name: "Captain", last_name: "Flint")

      get :index, params: { query: @billy_bones.email }
      expect(assigns[:contacts]).to eq([@billy_bones])
      expect(assigns[:current_query]).to eq(@billy_bones.email)
      expect(session[:contacts_current_query]).to eq(@billy_bones.email)
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @contacts = [FactoryGirl.create(:contact, user: current_user)]
        get :index, params: { page: 42 }, xhr: true

        expect(assigns[:current_page].to_i).to eq(42)
        expect(assigns[:contacts]).to eq([]) # page #42 should be empty if there's only one contact ;-)
        expect(session[:contacts_current_page].to_i).to eq(42)
        expect(response).to render_template("contacts/index")
      end

      it "should pick up saved page number from session" do
        session[:contacts_current_page] = 42
        @contacts = [FactoryGirl.create(:contact, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(42)
        expect(assigns[:contacts]).to eq([])
        expect(response).to render_template("contacts/index")
      end

      it "should reset current_page when query is altered" do
        session[:contacts_current_page] = 42
        session[:contacts_current_query] = "bill"
        @contacts = [FactoryGirl.create(:contact, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(1)
        expect(assigns[:contacts]).to eq(@contacts)
        expect(response).to render_template("contacts/index")
      end
    end

    describe "with mime type of JSON" do
      it "should render all contacts as JSON" do
        expect(@controller).to receive(:get_contacts).and_return(contacts = double("Array of Contacts"))
        expect(contacts).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render all contacts as xml" do
        expect(@controller).to receive(:get_contacts).and_return(contacts = double("Array of Contacts"))
        expect(contacts).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        expect(response.body).to eq("generated XML")
      end
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do
    describe "with mime type of HTML" do
      before(:each) do
        @contact = FactoryGirl.create(:contact, id: 42)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested contact as @contact" do
        get :show, params: { id: 42 }
        expect(assigns[:contact]).to eq(@contact)
        expect(assigns[:stage]).to eq(@stage)
        expect(assigns[:comment].attributes).to eq(@comment.attributes)
        expect(response).to render_template("contacts/show")
      end

      it "should update an activity when viewing the contact" do
        get :show, params: { id: @contact.id }
        expect(@contact.versions.last.event).to eq('view')
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested contact as JSON" do
        @contact = FactoryGirl.create(:contact, id: 42)
        expect(Contact).to receive(:find).and_return(@contact)
        expect(@contact).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render the requested contact as xml" do
        @contact = FactoryGirl.create(:contact, id: 42)
        expect(Contact).to receive(:find).and_return(@contact)
        expect(@contact).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated XML")
      end
    end

    describe "contact got deleted or otherwise unavailable" do
      it "should redirect to contact index if the contact got deleted" do
        @contact = FactoryGirl.create(:contact, user: current_user)
        @contact.destroy

        get :show, params: { id: @contact.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(contacts_path)
      end

      it "should redirect to contact index if the contact is protected" do
        @private = FactoryGirl.create(:contact, user: FactoryGirl.create(:user), access: "Private")

        get :show, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(contacts_path)
      end

      it "should return 404 (Not Found) XML error" do
        @contact = FactoryGirl.create(:contact, user: current_user)
        @contact.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, params: { id: @contact.id }
        expect(response.code).to eq("404") # :not_found
      end
    end
  end

  # GET /contacts/new
  # GET /contacts/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do
    it "should expose a new contact as @contact and render [new] template" do
      @contact = Contact.new(user: current_user,
                             access: Setting.default_access)
      @account = Account.new(user: current_user)
      @accounts = [FactoryGirl.create(:account, user: current_user)]

      get :new, xhr: true
      expect(assigns[:contact].attributes).to eq(@contact.attributes)
      expect(assigns[:account].attributes).to eq(@account.attributes)
      expect(assigns[:accounts]).to eq(@accounts)
      expect(assigns[:opportunity]).to eq(nil)
      expect(response).to render_template("contacts/new")
    end

    it "should created an instance of related object when necessary" do
      @opportunity = FactoryGirl.create(:opportunity)

      get :new, params: { related: "opportunity_#{@opportunity.id}" }, xhr: true
      expect(assigns[:opportunity]).to eq(@opportunity)
    end

    describe "(when creating related contact)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = FactoryGirl.create(:account)
        @account.destroy

        get :new, params: { related: "account_#{@account.id}" }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.href = "/accounts";')
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = FactoryGirl.create(:account, access: "Private")

        get :new, params: { related: "account_#{@account.id}" }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.href = "/accounts";')
      end
    end
  end

  # GET /contacts/field_group                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET field_group" do
    context "with an existing tag" do
      before :each do
        @tag = FactoryGirl.create(:tag)
      end

      it "should return with an existing tag name" do
        get :field_group, params: { tag: @tag.name }, xhr: true
        assigns[:tag].name == @tag.name
      end

      it "should have the same count of tags" do
        get :field_group, params: { tag:  @tag.name }, xhr: true
        expect(Tag.count).to equal(1)
      end
    end

    context "without an existing tag" do
      it "should not find a tag" do
        tag_name = "New-Tag"
        get :field_group, params: { tag: tag_name }, xhr: true
        expect(assigns[:tag]).to eql(nil)
      end

      it "should have the same count of tags" do
        tag_name = "New-Tag-1"
        get :field_group, params: { tag: tag_name }, xhr: true
        expect(Tag.count).to equal(0)
      end
    end
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose the requested contact as @contact and render [edit] template" do
      @contact = FactoryGirl.create(:contact, id: 42, user: current_user, lead: nil)
      @account = Account.new(user: current_user)

      get :edit, params: { id: 42 }, xhr: true
      expect(assigns[:contact]).to eq(@contact)
      expect(assigns[:account].attributes).to eq(@account.attributes)
      expect(assigns[:previous]).to eq(nil)
      expect(response).to render_template("contacts/edit")
    end

    it "should expose the requested contact as @contact and linked account as @account" do
      @account = FactoryGirl.create(:account, id: 99)
      @contact = FactoryGirl.create(:contact, id: 42, user: current_user, lead: nil)
      FactoryGirl.create(:account_contact, account: @account, contact: @contact)

      get :edit, params: { id: 42 }, xhr: true
      expect(assigns[:contact]).to eq(@contact)
      expect(assigns[:account]).to eq(@account)
    end

    it "should expose previous contact as @previous when necessary" do
      @contact = FactoryGirl.create(:contact, id: 42)
      @previous = FactoryGirl.create(:contact, id: 1992)

      get :edit, params: { id: 42, previous: 1992 }, xhr: true
      expect(assigns[:previous]).to eq(@previous)
    end

    describe "(contact got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the contact got deleted" do
        @contact = FactoryGirl.create(:contact, user: current_user)
        @contact.destroy

        get :edit, params: { id: @contact.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the contact is protected" do
        @private = FactoryGirl.create(:contact, user: FactoryGirl.create(:user), access: "Private")

        get :edit, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous contact got deleted or is otherwise unavailable)" do
      before(:each) do
        @contact = FactoryGirl.create(:contact, user: current_user)
        @previous = FactoryGirl.create(:contact, user: FactoryGirl.create(:user))
      end

      it "should notify the view if previous contact got deleted" do
        @previous.destroy

        get :edit, params: { id: @contact.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("contacts/edit")
      end

      it "should notify the view if previous contact got protected" do
        @previous.update_attribute(:access, "Private")

        get :edit, params: { id: @contact.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("contacts/edit")
      end
    end
  end

  # POST /contacts
  # POST /contacts.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do
    describe "with valid params" do
      it "should expose a newly created contact as @contact and render [create] template" do
        @contact = FactoryGirl.build(:contact, first_name: "Billy", last_name: "Bones")
        allow(Contact).to receive(:new).and_return(@contact)

        post :create, params: { contact: { first_name: "Billy", last_name: "Bones" }, account: { name: "Hello world" } }, xhr: true
        expect(assigns(:contact)).to eq(@contact)
        expect(assigns(:contact).reload.account.name).to eq("Hello world")
        expect(response).to render_template("contacts/create")
      end

      it "should be able to associate newly created contact with the opportunity" do
        @opportunity = FactoryGirl.create(:opportunity, id: 987)
        @contact = FactoryGirl.build(:contact)
        allow(Contact).to receive(:new).and_return(@contact)

        post :create, params: { contact: { first_name: "Billy" }, account: {}, opportunity: 987 }, xhr: true
        expect(assigns(:contact).opportunities).to include(@opportunity)
        expect(response).to render_template("contacts/create")
      end

      it "should reload contacts to update pagination if called from contacts index" do
        @contact = FactoryGirl.build(:contact, user: current_user)
        allow(Contact).to receive(:new).and_return(@contact)

        request.env["HTTP_REFERER"] = "http://localhost/contacts"
        post :create, params: { contact: { first_name: "Billy", last_name: "Bones" }, account: {} }, xhr: true
        expect(assigns[:contacts]).to eq([@contact])
      end

      it "should add a new comment to the newly created contact when specified" do
        @contact = FactoryGirl.build(:contact, user: current_user)
        allow(Contact).to receive(:new).and_return(@contact)

        post :create, params: { contact: { first_name: "Testy", last_name: "McTest" }, account: { name: "Hello world" }, comment_body: "Awesome comment is awesome" }, xhr: true
        expect(assigns[:contact].comments.map(&:comment)).to include("Awesome comment is awesome")
      end
    end

    describe "with invalid params" do
      before(:each) do
        @contact = FactoryGirl.build(:contact, first_name: nil, user: current_user, lead: nil)
        allow(Contact).to receive(:new).and_return(@contact)
      end

      # Redraw [create] form with selected account.
      it "should redraw [Create Contact] form with selected account" do
        @account = FactoryGirl.create(:account, id: 42, user: current_user)

        # This redraws [create] form with blank account.
        post :create, params: { contact: {}, account: { id: 42, user_id: current_user.id } }, xhr: true
        expect(assigns(:contact)).to eq(@contact)
        expect(assigns(:account)).to eq(@account)
        expect(assigns(:accounts)).to eq([@account])
        expect(response).to render_template("contacts/create")
      end

      # Redraw [create] form with related account.
      it "should redraw [Create Contact] form with related account" do
        @account = FactoryGirl.create(:account, id: 123, user: current_user)

        request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
        post :create, params: { contact: { first_name: nil }, account: { name: nil, user_id: current_user.id } }, xhr: true
        expect(assigns(:contact)).to eq(@contact)
        expect(assigns(:account)).to eq(@account)
        expect(assigns(:accounts)).to eq([@account])
        expect(response).to render_template("contacts/create")
      end

      it "should redraw [Create Contact] form with blank account" do
        @accounts = [FactoryGirl.create(:account, user: current_user)]
        @account = Account.new(user: current_user)

        post :create, params: { contact: { first_name: nil }, account: { name: nil, user_id: current_user.id } }, xhr: true
        expect(assigns(:contact)).to eq(@contact)
        expect(assigns(:account).attributes).to eq(@account.attributes)
        expect(assigns(:accounts)).to eq(@accounts)
        expect(response).to render_template("contacts/create")
      end

      it "should preserve Opportunity when called from Oppotuunity page" do
        @opportunity = FactoryGirl.create(:opportunity, id: 987)

        post :create, params: { contact: {}, account: {}, opportunity: 987 }, xhr: true
        expect(assigns(:opportunity)).to eq(@opportunity)
        expect(response).to render_template("contacts/create")
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update the requested contact and render [update] template" do
        @contact = FactoryGirl.create(:contact, id: 42, first_name: "Billy")

        put :update, params: { id: 42, contact: { first_name: "Bones" }, account: {} }, xhr: true
        expect(assigns[:contact].first_name).to eq("Bones")
        expect(assigns[:contact]).to eq(@contact)
        expect(response).to render_template("contacts/update")
      end

      it "should be able to create a new account and link it to the contact" do
        @contact = FactoryGirl.create(:contact, id: 42, first_name: "Billy")

        put :update, params: { id: 42, contact: { first_name: "Bones" }, account: { name: "new account" } }, xhr: true
        expect(assigns[:contact].first_name).to eq("Bones")
        expect(assigns[:contact].account.name).to eq("new account")
      end

      it "should be able to link existing account with the contact" do
        @account = FactoryGirl.create(:account, id: 99, name: "Hello world")
        @contact = FactoryGirl.create(:contact, id: 42, first_name: "Billy")

        put :update, params: { id: 42, contact: { first_name: "Bones" }, account: { id: 99 } }, xhr: true
        expect(assigns[:contact].first_name).to eq("Bones")
        expect(assigns[:contact].account.id).to eq(99)
      end

      it "should update contact permissions when sharing with specific users" do
        @contact = FactoryGirl.create(:contact, id: 42, access: "Public")

        put :update, params: { id: 42, contact: { first_name: "Hello", access: "Shared", user_ids: [7, 8] }, account: {} }, xhr: true
        expect(assigns[:contact].access).to eq("Shared")
        expect(assigns[:contact].user_ids.sort).to eq([7, 8])
        expect(assigns[:contact]).to eq(@contact)
      end

      describe "contact got deleted or otherwise unavailable" do
        it "should reload current page is the contact got deleted" do
          @contact = FactoryGirl.create(:contact, user: current_user)
          @contact.destroy

          put :update, params: { id: @contact.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the contact is protected" do
          @private = FactoryGirl.create(:contact, user: FactoryGirl.create(:user), access: "Private")

          put :update, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "with invalid params" do
      it "should not update the contact, but still expose it as @contact and render [update] template" do
        @contact = FactoryGirl.create(:contact, id: 42, user: current_user, first_name: "Billy", lead: nil)

        put :update, params: { id: 42, contact: { first_name: nil }, account: {} }, xhr: true
        expect(assigns[:contact].reload.first_name).to eq("Billy")
        expect(assigns[:contact]).to eq(@contact)
        expect(response).to render_template("contacts/update")
      end

      it "should expose existing account as @account if selected" do
        @account = FactoryGirl.create(:account, id: 99)
        @contact = FactoryGirl.create(:contact, id: 42, account: @account)

        put :update, params: { id: 42, contact: { first_name: nil }, account: { id: 99 } }, xhr: true
        expect(assigns[:account]).to eq(@account)
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      @contact = FactoryGirl.create(:contact, user: current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested contact and render [destroy] template" do
        delete :destroy, params: { id: @contact.id }, xhr: true

        expect { Contact.find(@contact.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to render_template("contacts/destroy")
      end

      describe "when called from Contacts index page" do
        before(:each) do
          request.env["HTTP_REFERER"] = "http://localhost/contacts"
        end

        it "should try previous page and render index action if current page has no contacts" do
          session[:contacts_current_page] = 42
          delete :destroy, params: { id: @contact.id }, xhr: true

          expect(session[:contacts_current_page]).to eq(41)
          expect(response).to render_template("contacts/index")
        end

        it "should render index action when deleting last contact" do
          session[:contacts_current_page] = 1
          delete :destroy, params: { id: @contact.id }, xhr: true

          expect(session[:contacts_current_page]).to eq(1)
          expect(response).to render_template("contacts/index")
        end
      end

      describe "when called from related asset page page" do
        it "should reset current page to 1" do
          request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
          delete :destroy, params: { id: @contact.id }, xhr: true

          expect(session[:contacts_current_page]).to eq(1)
          expect(response).to render_template("contacts/destroy")
        end
      end

      describe "contact got deleted or otherwise unavailable" do
        it "should reload current page is the contact got deleted" do
          @contact = FactoryGirl.create(:contact, user: current_user)
          @contact.destroy

          delete :destroy, params: { id: @contact.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the contact is protected" do
          @private = FactoryGirl.create(:contact, user: FactoryGirl.create(:user), access: "Private")

          delete :destroy, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Contacts index when a contact gets deleted from its landing page" do
        delete :destroy, params: { id: @contact.id }

        expect(flash[:notice]).not_to eq(nil)
        expect(response).to redirect_to(contacts_path)
      end

      it "should redirect to contact index with the flash message is the contact got deleted" do
        @contact = FactoryGirl.create(:contact, user: current_user)
        @contact.destroy

        delete :destroy, params: { id: @contact.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(contacts_path)
      end

      it "should redirect to contact index with the flash message if the contact is protected" do
        @private = FactoryGirl.create(:contact, user: FactoryGirl.create(:user), access: "Private")

        delete :destroy, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(contacts_path)
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
        @attachment = FactoryGirl.create(:task, asset: nil)
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
        @attachment = FactoryGirl.create(:task, asset: nil)
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
        @attachment = FactoryGirl.create(:task, asset: @model)
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
      @auto_complete_matches = [FactoryGirl.create(:contact, first_name: "Hello", last_name: "World", user: current_user)]
    end

    it_should_behave_like("auto complete")
  end

  # GET /contacts/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected contact preference" do
      get :redraw, params: { per_page: 42, view: "long", sort_by: "first_name", naming: "after" }, xhr: true
      expect(current_user.preference[:contacts_per_page].to_i).to eq(42)
      expect(current_user.preference[:contacts_index_view]).to eq("long")
      expect(current_user.preference[:contacts_sort_by]).to eq("contacts.first_name ASC")
      expect(current_user.preference[:contacts_naming]).to eq("after")
    end

    it "should set similar options for Leads" do
      get :redraw, params: { sort_by: "first_name", naming: "after" }, xhr: true
      expect(current_user.pref[:leads_sort_by]).to eq("leads.first_name ASC")
      expect(current_user.pref[:leads_naming]).to eq("after")
    end

    it "should reset current page to 1" do
      get :redraw, params: { per_page: 42, view: "long", sort_by: "first_name", naming: "after" }, xhr: true
      expect(session[:contacts_current_page]).to eq(1)
    end

    it "should select @contacts and render [index] template" do
      @contacts = [
        FactoryGirl.create(:contact, first_name: "Alice", user: current_user),
        FactoryGirl.create(:contact, first_name: "Bobby", user: current_user)
      ]

      get :redraw, params: { per_page: 1, sort_by: "first_name" }, xhr: true
      expect(assigns(:contacts)).to eq([@contacts.first])
      expect(response).to render_template("contacts/index")
    end
  end
end
