# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe LeadsController do
  before(:each) do
    login
    set_current_tab(:leads)
  end

  # GET /leads
  # GET /leads.xml                                                AJAX and HTML
  #----------------------------------------------------------------------------
  describe "responding to GET index" do
    it "should expose all leads as @leads and render [index] template" do
      @leads = [create(:lead, user: current_user)]

      get :index
      expect(assigns[:leads]).to eq(@leads)
      expect(response).to render_template("leads/index")
    end

    it "should collect the data for the leads sidebar" do
      @leads = [create(:lead, user: current_user)]
      @status = Setting.lead_status.dup

      get :index
      expect(assigns[:lead_status_total].keys.map(&:to_sym) - (@status << :all << :other)).to eq([])
    end

    it "should filter out leads by status" do
      controller.session[:leads_filter] = "new,contacted"
      @leads = [
        create(:lead, status: "new", user: current_user),
        create(:lead, status: "contacted", user: current_user)
      ]

      # This one should be filtered out.
      create(:lead, status: "rejected", user: current_user)

      get :index
      # NOTE: can't compare campaigns directly because of BigDecimals.
      expect(assigns[:leads].size).to eq(2)
      expect(assigns[:leads].map(&:status).sort).to eq(%w[contacted new])
    end

    it "should perform lookup using query string" do
      @billy_bones   = create(:lead, user: current_user, first_name: "Billy",   last_name: "Bones")
      @captain_flint = create(:lead, user: current_user, first_name: "Captain", last_name: "Flint")

      get :index, params: { query: "bill" }
      expect(assigns[:leads]).to eq([@billy_bones])
      expect(assigns[:current_query]).to eq("bill")
      expect(session[:leads_current_query]).to eq("bill")
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @leads = [create(:lead, user: current_user)]
        get :index, params: { page: 42 }, xhr: true

        expect(assigns[:current_page].to_i).to eq(42)
        expect(assigns[:leads]).to eq([]) # page #42 should be empty if there's only one lead ;-)
        expect(session[:leads_current_page].to_i).to eq(42)
        expect(response).to render_template("leads/index")
      end

      it "should pick up saved page number from session" do
        session[:leads_current_page] = 42
        session[:leads_current_query] = "bill"
        @leads = [create(:lead, user: current_user)]
        get :index, params: { query: "bill" }, xhr: true

        expect(assigns[:current_page]).to eq(42)
        expect(assigns[:leads]).to eq([])
        expect(response).to render_template("leads/index")
      end

      it "should reset current_page when query is altered" do
        session[:leads_current_page] = 42
        session[:leads_current_query] = "bill"
        @leads = [create(:lead, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(1)
        expect(assigns[:leads]).to eq(@leads)
        expect(response).to render_template("leads/index")
      end
    end

    describe "with mime type of JSON" do
      it "should render all leads as JSON" do
        expect(@controller).to receive(:get_leads).and_return(leads = double("Array of Leads"))
        expect(leads).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render all leads as xml" do
        expect(@controller).to receive(:get_leads).and_return(leads = double("Array of Leads"))
        expect(leads).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        expect(response.body).to eq("generated XML")
      end
    end
  end

  # GET /leads/1
  # GET /leads/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do
    describe "with mime type of HTML" do
      before(:each) do
        @lead = create(:lead, id: 42, user: current_user)
        @comment = Comment.new
      end

      it "should expose the requested lead as @lead and render [show] template" do
        get :show, params: { id: 42 }
        expect(assigns[:lead]).to eq(@lead)
        expect(assigns[:comment].attributes).to eq(@comment.attributes)
        expect(response).to render_template("leads/show")
      end

      it "should update an activity when viewing the lead" do
        get :show, params: { id: @lead.id }
        expect(@lead.versions.last.event).to eq('view')
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested lead as JSON" do
        @lead = create(:lead, id: 42, user: current_user)
        expect(Lead).to receive(:find).and_return(@lead)
        expect(@lead).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render the requested lead as xml" do
        @lead = create(:lead, id: 42, user: current_user)
        expect(Lead).to receive(:find).and_return(@lead)
        expect(@lead).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated XML")
      end
    end

    describe "lead got deleted or otherwise unavailable" do
      it "should redirect to lead index if the lead got deleted" do
        @lead = create(:lead, user: current_user)
        @lead.destroy

        get :show, params: { id: @lead.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(leads_path)
      end

      it "should redirect to lead index if the lead is protected" do
        @private = create(:lead, user: create(:user), access: "Private")

        get :show, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(leads_path)
      end

      it "should return 404 (Not Found) JSON error" do
        @lead = create(:lead, user: current_user)
        @lead.destroy
        request.env["HTTP_ACCEPT"] = "application/json"

        get :show, params: { id: @lead.id }
        expect(response.code).to eq("404") # :not_found
      end

      it "should return 404 (Not Found) XML error" do
        @lead = create(:lead, user: current_user)
        @lead.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, params: { id: @lead.id }
        expect(response.code).to eq("404") # :not_found
      end
    end
  end

  # GET /leads/new
  # GET /leads/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do
    it "should expose a new lead as @lead and render [new] template" do
      @lead = build(:lead, user: current_user, campaign: nil)
      allow(Lead).to receive(:new).and_return(@lead)
      @campaigns = [create(:campaign, user: current_user)]

      get :new, xhr: true
      expect(assigns[:lead].attributes).to eq(@lead.attributes)
      expect(assigns[:campaigns]).to eq(@campaigns)
      expect(response).to render_template("leads/new")
    end

    it "should create related object when necessary" do
      @campaign = create(:campaign, id: 123)

      get :new, params: { related: "campaign_123" }, xhr: true
      expect(assigns[:campaign]).to eq(@campaign)
    end

    describe "(when creating related lead)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @campaign = create(:campaign)
        @campaign.destroy

        get :new, params: { related: "campaign_#{@campaign.id}" }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.href = "/campaigns";')
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @campaign = create(:campaign, access: "Private")

        get :new, params: { related: "campaign_#{@campaign.id}" }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.href = "/campaigns";')
      end
    end
  end

  # GET /leads/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose the requested lead as @lead and render [edit] template" do
      @lead = create(:lead, id: 42, user: current_user, campaign: nil)
      @campaigns = [create(:campaign, user: current_user)]

      get :edit, params: { id: 42 }, xhr: true
      expect(assigns[:lead]).to eq(@lead)
      expect(assigns[:campaigns]).to eq(@campaigns)
      expect(response).to render_template("leads/edit")
    end

    it "should find previous lead when necessary" do
      @lead = create(:lead, id: 42)
      @previous = create(:lead, id: 321)

      get :edit, params: { id: 42, previous: 321 }, xhr: true
      expect(assigns[:previous]).to eq(@previous)
    end

    describe "lead got deleted or is otherwise unavailable" do
      it "should reload current page with the flash message if the lead got deleted" do
        @lead = create(:lead, user: current_user)
        @lead.destroy

        get :edit, params: { id: @lead.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the lead is protected" do
        @private = create(:lead, user: create(:user), access: "Private")

        get :edit, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous lead got deleted or is otherwise unavailable)" do
      before(:each) do
        @lead = create(:lead, user: current_user)
        @previous = create(:lead, user: create(:user))
      end

      it "should notify the view if previous lead got deleted" do
        @previous.destroy

        get :edit, params: { id: @lead.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("leads/edit")
      end

      it "should notify the view if previous lead got protected" do
        @previous.update_attribute(:access, "Private")

        get :edit, params: { id: @lead.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("leads/edit")
      end
    end
  end

  # POST /leads
  # POST /leads.xml                                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do
    describe "with valid params" do
      it "should expose a newly created lead as @lead and render [create] template" do
        @lead = build(:lead, user: current_user, campaign: nil)
        allow(Lead).to receive(:new).and_return(@lead)
        @campaigns = [create(:campaign, user: current_user)]

        post :create, params: { lead: { first_name: "Billy", last_name: "Bones" } }, xhr: true
        expect(assigns(:lead)).to eq(@lead)
        expect(assigns(:campaigns)).to eq(@campaigns)
        expect(assigns[:lead_status_total]).to be_nil
        expect(response).to render_template("leads/create")
      end

      it "should copy selected campaign permissions unless asked otherwise" do
        he  = create(:user, id: 7)
        she = create(:user, id: 8)
        @campaign = build(:campaign, access: "Shared")
        @campaign.permissions << build(:permission, user: he,  asset: @campaign)
        @campaign.permissions << build(:permission, user: she, asset: @campaign)
        @campaign.save

        @lead = build(:lead, campaign: @campaign, user: current_user, access: "Shared")
        allow(Lead).to receive(:new).and_return(@lead)

        post :create, params: { lead: { first_name: "Billy", last_name: "Bones", access: "Campaign", user_ids: %w[7 8] }, campaign: @campaign.id }, xhr: true
        expect(assigns(:lead)).to eq(@lead)
        expect(@lead.reload.access).to eq("Shared")
        expect(@lead.permissions.map(&:user_id).sort).to eq([7, 8])
        expect(@lead.permissions.map(&:asset_id)).to eq([@lead.id, @lead.id])
        expect(@lead.permissions.map(&:asset_type)).to eq(%w[Lead Lead])
      end

      it "should get the data to update leads sidebar if called from leads index" do
        @lead = build(:lead, user: current_user, campaign: nil)
        allow(Lead).to receive(:new).and_return(@lead)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        post :create, params: { lead: { first_name: "Billy", last_name: "Bones" } }, xhr: true
        expect(assigns[:lead_status_total]).to be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should reload leads to update pagination if called from leads index" do
        @lead = build(:lead, user: current_user, campaign: nil)
        allow(Lead).to receive(:new).and_return(@lead)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        post :create, params: { lead: { first_name: "Billy", last_name: "Bones" } }, xhr: true
        expect(assigns[:leads]).to eq([@lead])
      end

      it "should reload lead campaign if called from campaign landing page" do
        @campaign = create(:campaign)
        @lead = build(:lead, user: current_user, campaign: @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        put :create, params: { lead: { first_name: "Billy", last_name: "Bones" }, campaign: @campaign.id }, xhr: true
        expect(assigns[:campaign]).to eq(@campaign)
      end

      it "should add a new comment to the newly created lead when specified" do
        @lead = create(:lead)
        allow(Lead).to receive(:new).and_return(@lead)
        post :create, params: { lead: { first_name: "Test", last_name: "Lead" }, comment_body: "This is an important lead." }, xhr: true
        expect(@lead.reload.comments.map(&:comment)).to include("This is an important lead.")
      end
    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved lead as @lead and still render [create] template" do
        @lead = build(:lead, user: current_user, first_name: nil, campaign: nil)
        allow(Lead).to receive(:new).and_return(@lead)
        @campaigns = [create(:campaign, user: current_user)]

        post :create, params: { lead: { first_name: nil } }, xhr: true
        expect(assigns(:lead)).to eq(@lead)
        expect(assigns(:campaigns)).to eq(@campaigns)
        expect(assigns[:lead_status_total]).to eq(nil)
        expect(response).to render_template("leads/create")
      end
    end
  end

  # PUT /leads/1
  # PUT /leads/1.xml
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update the requested lead, expose it as @lead, and render [update] template" do
        @lead = create(:lead, first_name: "Billy", user: current_user)

        put :update, params: { id: @lead.id, lead: { first_name: "Bones" } }, xhr: true
        expect(@lead.reload.first_name).to eq("Bones")
        expect(assigns[:lead]).to eq(@lead)
        expect(assigns[:lead_status_total]).to eq(nil)
        expect(response).to render_template("leads/update")
      end

      it "should update lead status" do
        @lead = create(:lead, status: "new", user: current_user)

        put :update, params: { id: @lead.id, lead: { status: "rejected" } }, xhr: true
        expect(@lead.reload.status).to eq("rejected")
      end

      it "should update lead source" do
        @lead = create(:lead, source: "campaign", user: current_user)

        put :update, params: { id: @lead.id, lead: { source: "cald_call" } }, xhr: true
        expect(@lead.reload.source).to eq("cald_call")
      end

      it "should update lead campaign" do
        @campaigns = { old: create(:campaign), new: create(:campaign) }
        @lead = create(:lead, campaign: @campaigns[:old])

        put :update, params: { id: @lead.id, lead: { campaign_id: @campaigns[:new].id } }, xhr: true
        expect(@lead.reload.campaign).to eq(@campaigns[:new])
      end

      it "should decrement campaign leads count if campaign has been removed" do
        @campaign = create(:campaign)
        @lead = create(:lead, campaign: @campaign)
        @count = @campaign.reload.leads_count

        put :update, params: { id: @lead, lead: { campaign_id: nil } }, xhr: true
        expect(@lead.reload.campaign).to eq(nil)
        expect(@campaign.reload.leads_count).to eq(@count - 1)
      end

      it "should increment campaign leads count if campaign has been assigned" do
        @campaign = create(:campaign)
        @lead = create(:lead, campaign: nil)
        @count = @campaign.leads_count

        put :update, params: { id: @lead, lead: { campaign_id: @campaign.id } }, xhr: true
        expect(@lead.reload.campaign).to eq(@campaign)
        expect(@campaign.reload.leads_count).to eq(@count + 1)
      end

      it "should update both campaign leads counts if reassigned to a new campaign" do
        @campaigns = { old: create(:campaign), new: create(:campaign) }
        @lead = create(:lead, campaign: @campaigns[:old])
        @counts = { old: @campaigns[:old].reload.leads_count, new: @campaigns[:new].leads_count }

        put :update, params: { id: @lead, lead: { campaign_id: @campaigns[:new].id } }, xhr: true
        expect(@lead.reload.campaign).to eq(@campaigns[:new])
        expect(@campaigns[:old].reload.leads_count).to eq(@counts[:old] - 1)
        expect(@campaigns[:new].reload.leads_count).to eq(@counts[:new] + 1)
      end

      it "should update shared permissions for the lead" do
        @lead = create(:lead, user: current_user)
        he = create(:user, id: 7)
        she = create(:user, id: 8)

        put :update, params: { id: @lead.id, lead: { access: "Shared", user_ids: %w[7 8] } }, xhr: true
        expect(@lead.user_ids.sort).to eq([he.id, she.id])
      end

      it "should get the data for leads sidebar when called from leads index" do
        @lead = create(:lead)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        put :update, params: { id: @lead.id, lead: { first_name: "Billy" } }, xhr: true
        expect(assigns[:lead_status_total]).not_to be_nil
        expect(assigns[:lead_status_total]).to be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should reload lead campaign if called from campaign landing page" do
        @campaign = create(:campaign)
        @lead = create(:lead, campaign: @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        put :update, params: { id: @lead.id, lead: { first_name: "Hello" } }, xhr: true
        expect(assigns[:campaign]).to eq(@campaign)
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the lead got deleted" do
          @lead = create(:lead, user: current_user)
          @lead.destroy

          put :update, params: { id: @lead.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the lead is protected" do
          @private = create(:lead, user: create(:user), access: "Private")

          put :update, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "with invalid params" do
      it "should not update the lead, but still expose it as @lead and render [update] template" do
        @lead = create(:lead, id: 42, user: current_user, campaign: nil)
        @campaigns = [create(:campaign, user: current_user)]

        put :update, params: { id: 42, lead: { first_name: nil } }, xhr: true
        expect(assigns[:lead]).to eq(@lead)
        expect(assigns[:campaigns]).to eq(@campaigns)
        expect(response).to render_template("leads/update")
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.xml                                           AJAX and HTML
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      @lead = create(:lead, user: current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested lead and render [destroy] template" do
        delete :destroy, params: { id: @lead.id }, xhr: true

        expect(assigns[:leads]).to eq(nil) # @lead got deleted
        expect { Lead.find(@lead.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to render_template("leads/destroy")
      end

      describe "when called from Leads index page" do
        before(:each) do
          request.env["HTTP_REFERER"] = "http://localhost/leads"
        end

        it "should get data for the sidebar" do
          @another_lead = create(:lead, user: current_user)

          delete :destroy, params: { id: @lead.id }, xhr: true
          expect(assigns[:leads]).to eq([@another_lead]) # @lead got deleted
          expect(assigns[:lead_status_total]).not_to be_nil
          expect(assigns[:lead_status_total]).to be_an_instance_of(HashWithIndifferentAccess)
          expect(response).to render_template("leads/destroy")
        end

        it "should try previous page and render index action if current page has no leads" do
          session[:leads_current_page] = 42

          delete :destroy, params: { id: @lead.id }, xhr: true
          expect(session[:leads_current_page]).to eq(41)
          expect(response).to render_template("leads/index")
        end

        it "should render index action when deleting last lead" do
          session[:leads_current_page] = 1

          delete :destroy, params: { id: @lead.id }, xhr: true
          expect(session[:leads_current_page]).to eq(1)
          expect(response).to render_template("leads/index")
        end
      end

      describe "when called from campaign landing page" do
        before(:each) do
          @campaign = create(:campaign)
          @lead = create(:lead, user: current_user, campaign: @campaign)
          request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        end

        it "should reset current page to 1" do
          delete :destroy, params: { id: @lead.id }, xhr: true
          expect(session[:leads_current_page]).to eq(1)
          expect(response).to render_template("leads/destroy")
        end

        it "should reload campaiign to be able to refresh its summary" do
          delete :destroy, params: { id: @lead.id }, xhr: true
          expect(assigns[:campaign]).to eq(@campaign)
          expect(response).to render_template("leads/destroy")
        end
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the lead got deleted" do
          @lead = create(:lead, user: current_user)
          @lead.destroy

          delete :destroy, params: { id: @lead.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the lead is protected" do
          @private = create(:lead, user: create(:user), access: "Private")

          delete :destroy, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Leads index when a lead gets deleted from its landing page" do
        delete :destroy, params: { id: @lead.id }
        expect(flash[:notice]).not_to eq(nil)
        expect(session[:leads_current_page]).to eq(1)
        expect(response).to redirect_to(leads_path)
      end

      it "should redirect to lead index with the flash message is the lead got deleted" do
        @lead = create(:lead, user: current_user)
        @lead.destroy

        delete :destroy, params: { id: @lead.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(leads_path)
      end

      it "should redirect to lead index with the flash message if the lead is protected" do
        @private = create(:lead, user: create(:user), access: "Private")

        delete :destroy, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(leads_path)
      end
    end
  end

  # GET /leads/1/convert
  # GET /leads/1/convert.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET convert" do
    it "should should collect necessary data and render [convert] template" do
      @campaign = create(:campaign, user: current_user)
      @lead = create(:lead, user: current_user, campaign: @campaign, source: "cold_call")
      @accounts = [create(:account, user: current_user)]
      @account = Account.new(user: current_user, name: @lead.company, access: "Lead")
      @opportunity = Opportunity.new(user: current_user, access: "Lead", stage: "prospecting", campaign: @lead.campaign, source: @lead.source)

      get :convert, params: { id: @lead.id }, xhr: true
      expect(assigns[:lead]).to eq(@lead)
      expect(assigns[:accounts]).to eq(@accounts)
      expect(assigns[:account].attributes).to eq(@account.attributes)
      expect(assigns[:opportunity].attributes).to eq(@opportunity.attributes)
      expect(assigns[:opportunity].campaign).to eq(@opportunity.campaign)
      expect(response).to render_template("leads/convert")
    end

    describe "(lead got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the lead got deleted" do
        @lead = create(:lead, user: current_user)
        @lead.destroy

        get :convert, params: { id: @lead.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the lead is protected" do
        @private = create(:lead, user: create(:user), access: "Private")

        get :convert, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous lead got deleted or is otherwise unavailable)" do
      before(:each) do
        @lead = create(:lead, user: current_user)
        @previous = create(:lead, user: create(:user))
      end

      it "should notify the view if previous lead got deleted" do
        @previous.destroy

        get :convert, params: { id: @lead.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("leads/convert")
      end

      it "should notify the view if previous lead got protected" do
        @previous.update_attribute(:access, "Private")

        get :convert, params: { id: @lead.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("leads/convert")
      end
    end
  end

  # PUT /leads/1/promote
  # PUT /leads/1/promote.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT promote" do
    it "on success: should change lead's status to [converted] and render [promote] template" do
      @lead = create(:lead, id: 42, user: current_user, campaign: nil)
      @account = create(:account, id: 123, user: current_user)
      @opportunity = build(:opportunity, user: current_user, campaign: @lead.campaign,
                                         account: @account)
      allow(Opportunity).to receive(:new).and_return(@opportunity)
      @contact = build(:contact, user: current_user, lead: @lead)
      allow(Contact).to receive(:new).and_return(@contact)

      put :promote, params: { id: 42, account: { id: 123 }, opportunity: { name: "Hello" } }, xhr: true
      expect(@lead.reload.status).to eq("converted")
      expect(assigns[:lead]).to eq(@lead)
      expect(assigns[:account]).to eq(@account)
      expect(assigns[:accounts]).to eq([@account])
      expect(assigns[:opportunity]).to eq(@opportunity)
      expect(assigns[:contact]).to eq(@contact)
      expect(assigns[:stage]).to be_instance_of(Array)
      expect(response).to render_template("leads/promote")
    end

    it "should copy lead permissions to newly created account and opportunity when asked so" do
      he  = create(:user, id: 7)
      she = create(:user, id: 8)
      @lead = build(:lead, access: "Shared")
      @lead.permissions << build(:permission, user: he,  asset: @lead)
      @lead.permissions << build(:permission, user: she, asset: @lead)
      @lead.save
      @account = build(:account, user: current_user, access: "Shared")
      @account.permissions << create(:permission, user: he,  asset: @account)
      @account.permissions << create(:permission, user: she, asset: @account)
      allow(@account).to receive(:new).and_return(@account)
      @opportunity = build(:opportunity, user: current_user, access: "Shared")
      @opportunity.permissions << create(:permission, user: he,  asset: @opportunity)
      @opportunity.permissions << create(:permission, user: she, asset: @opportunity)
      allow(@opportunity).to receive(:new).and_return(@opportunity)

      put :promote, params: { id: @lead.id, access: "Lead", account: { name: "Hello", access: "Lead", user_id: current_user.id }, opportunity: { name: "World", access: "Lead", user_id: current_user.id } }, xhr: true
      expect(@account.access).to eq("Shared")
      expect(@account.permissions.map(&:user_id).sort).to eq([7, 8])
      expect(@account.permissions.map(&:asset_id)).to eq([@account.id, @account.id])
      expect(@account.permissions.map(&:asset_type)).to eq(%w[Account Account])
      expect(@opportunity.access).to eq("Shared")
      expect(@opportunity.permissions.map(&:user_id).sort).to eq([7, 8])
      expect(@opportunity.permissions.map(&:asset_id)).to eq([@opportunity.id, @opportunity.id])
      expect(@opportunity.permissions.map(&:asset_type)).to eq(%w[Opportunity Opportunity])
    end

    it "should assign lead's campaign to the newly created opportunity" do
      @campaign = create(:campaign)
      @lead = create(:lead, user: current_user, campaign: @campaign)

      put :promote, params: { id: @lead.id, account: { name: "Hello" }, opportunity: { name: "Hello", campaign_id: @campaign.id } }, xhr: true
      expect(assigns[:opportunity].campaign).to eq(@campaign)
    end

    it "should assign lead's source to the newly created opportunity" do
      @lead = create(:lead, user: current_user, source: "cold_call")

      put :promote, params: { id: @lead.id, account: { name: "Hello" }, opportunity: { name: "Hello", source: @lead.source } }, xhr: true
      expect(assigns[:opportunity].source).to eq(@lead.source)
    end

    it "should get the data for leads sidebar when called from leads index" do
      @lead = create(:lead)
      request.env["HTTP_REFERER"] = "http://localhost/leads"

      put :promote, params: { id: @lead.id, account: { name: "Hello" }, opportunity: {} }, xhr: true
      expect(assigns[:lead_status_total]).not_to be_nil
      expect(assigns[:lead_status_total]).to be_an_instance_of(HashWithIndifferentAccess)
    end

    it "should reload lead campaign if called from campaign landing page" do
      @campaign = create(:campaign)
      @lead = create(:lead, campaign: @campaign)
      request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

      put :promote, params: { id: @lead.id, account: { name: "Hello" }, opportunity: {} }, xhr: true
      expect(assigns[:campaign]).to eq(@campaign)
    end

    it "on failure: should not change lead's status and still render [promote] template" do
      @lead = create(:lead, id: 42, user: current_user, status: "new")
      @account = create(:account, id: 123, user: current_user)
      @contact = build(:contact, first_name: nil) # make it fail
      allow(Contact).to receive(:new).and_return(@contact)

      put :promote, params: { id: 42, account: { id: 123 } }, xhr: true
      expect(@lead.reload.status).to eq("new")
      expect(response).to render_template("leads/promote")
    end

    describe "lead got deleted or otherwise unavailable" do
      it "should reload current page with the flash message if the lead got deleted" do
        @lead = create(:lead, user: current_user)
        @lead.destroy

        put :promote, params: { id: @lead.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the lead is protected" do
        @private = create(:lead, user: create(:user), access: "Private")

        put :promote, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end
  end

  # PUT /leads/1/reject
  # PUT /leads/1/reject.xml                                       AJAX and HTML
  #----------------------------------------------------------------------------
  describe "responding to PUT reject" do
    before(:each) do
      @lead = create(:lead, user: current_user, status: "new")
    end

    describe "AJAX request" do
      it "should reject the requested lead and render [reject] template" do
        put :reject, params: { id: @lead.id }, xhr: true

        expect(assigns[:lead]).to eq(@lead.reload)
        expect(@lead.status).to eq("rejected")
        expect(response).to render_template("leads/reject")
      end

      it "should get the data for leads sidebar when called from leads index" do
        request.env["HTTP_REFERER"] = "http://localhost/leads"
        put :reject, params: { id: @lead.id }, xhr: true
        expect(assigns[:lead_status_total]).not_to be_nil
        expect(assigns[:lead_status_total]).to be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should reload lead campaign if called from campaign landing page" do
        @campaign = create(:campaign)
        @lead = create(:lead, campaign: @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        put :reject, params: { id: @lead.id }, xhr: true
        expect(assigns[:campaign]).to eq(@campaign)
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the lead got deleted" do
          @lead = create(:lead, user: current_user)
          @lead.destroy

          put :reject, params: { id: @lead.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the lead is protected" do
          @private = create(:lead, user: create(:user), access: "Private")

          put :reject, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Leads index when a lead gets rejected from its landing page" do
        put :reject, params: { id: @lead.id }

        expect(assigns[:lead]).to eq(@lead.reload)
        expect(@lead.status).to eq("rejected")
        expect(flash[:notice]).not_to eq(nil)
        expect(response).to redirect_to(leads_path)
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should redirect to lead index if the lead got deleted" do
          @lead = create(:lead, user: current_user)
          @lead.destroy

          put :reject, params: { id: @lead.id }
          expect(flash[:warning]).not_to eq(nil)
          expect(response).to redirect_to(leads_path)
        end

        it "should redirect to lead index if the lead is protected" do
          @private = create(:lead, user: create(:user), access: "Private")

          put :reject, params: { id: @private.id }
          expect(flash[:warning]).not_to eq(nil)
          expect(response).to redirect_to(leads_path)
        end
      end
    end
  end

  # PUT /leads/1/attach
  # PUT /leads/1/attach.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = create(:lead)
        @attachment = create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end
  end

  # PUT /leads/1/attach
  # PUT /leads/1/attach.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = create(:lead)
        @attachment = create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end
  end

  # POST /leads/1/discard
  # POST /leads/1/discard.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST discard" do
    before(:each) do
      @attachment = create(:task, assigned_to: current_user)
      @model = create(:lead)
      @model.tasks << @attachment
    end

    it_should_behave_like("discard")
  end

  # POST /leads/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [create(:lead, first_name: "Hello", last_name: "World", user: current_user)]
    end

    it_should_behave_like("auto complete")
  end

  # GET /leads/redraw                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET redraw" do
    it "should save user selected lead preference" do
      get :redraw, params: { per_page: 42, view: "long", sort_by: "first_name", naming: "after" }, xhr: true
      expect(current_user.preference[:leads_per_page]).to eq(42)
      expect(current_user.preference[:leads_index_view]).to eq("long")
      expect(current_user.preference[:leads_sort_by]).to eq("leads.first_name ASC")
      expect(current_user.preference[:leads_naming]).to eq("after")
    end

    it "should set similar options for Contacts" do
      get :redraw, params: { sort_by: "first_name", naming: "after" }, xhr: true
      expect(current_user.pref[:contacts_sort_by]).to eq("contacts.first_name ASC")
      expect(current_user.pref[:contacts_naming]).to eq("after")
    end

    it "should reset current page to 1" do
      get :redraw, params: { per_page: 42, view: "long", sort_by: "first_name", naming: "after" }, xhr: true
      expect(session[:leads_current_page]).to eq(1)
    end

    it "should select @leads and render [index] template" do
      @leads = [
        create(:lead, first_name: "Alice", user: current_user),
        create(:lead, first_name: "Bobby", user: current_user)
      ]

      get :redraw, params: { per_page: 1, sort_by: "first_name" }, xhr: true
      expect(assigns(:leads)).to eq([@leads.first])
      expect(response).to render_template("leads/index")
    end
  end

  # POST /leads/filter                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST filter" do
    it "should filter out leads as @leads and render :index action" do
      session[:leads_filter] = "contacted,rejected"

      @leads = [create(:lead, user: current_user, status: "new")]
      post :filter, params: { status: "new" }, xhr: true
      expect(assigns[:leads]).to eq(@leads)
      expect(response).to be_successful
      expect(response).to render_template("leads/index")
    end

    it "should reset current page to 1" do
      @leads = []
      post :filter, params: { status: "new" }, xhr: true

      expect(session[:leads_current_page]).to eq(1)
    end
  end
end
