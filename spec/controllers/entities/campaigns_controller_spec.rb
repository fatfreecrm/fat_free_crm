# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe CampaignsController do
  def get_data_for_sidebar
    @status = Setting.campaign_status.dup
  end

  before(:each) do
    login
    set_current_tab(:campaigns)
  end

  # GET /campaigns
  # GET /campaigns.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do
    before(:each) do
      get_data_for_sidebar
    end

    it "should expose all campaigns as @campaigns and render [index] template" do
      @campaigns = [create(:campaign, user: current_user)]

      get :index
      expect(assigns[:campaigns]).to eq(@campaigns)
      expect(response).to render_template("campaigns/index")
    end

    it "should collect the data for the opportunities sidebar" do
      @campaigns = [create(:campaign, user: current_user)]

      get :index
      expect(assigns[:campaign_status_total].keys.map(&:to_sym) - (@status << :all << :other)).to eq([])
    end

    it "should filter out campaigns by status" do
      controller.session[:campaigns_filter] = "planned,started"
      @campaigns = [
        create(:campaign, user: current_user, status: "started"),
        create(:campaign, user: current_user, status: "planned")
      ]

      # This one should be filtered out.
      create(:campaign, user: current_user, status: "completed")

      get :index
      # Note: can't compare campaigns directly because of BigDecimal objects.
      expect(assigns[:campaigns].size).to eq(2)
      expect(assigns[:campaigns].map(&:status).sort).to eq(%w[planned started])
    end

    it "should perform lookup using query string" do
      @first  = create(:campaign, user: current_user, name: "Hello, world!")
      @second = create(:campaign, user: current_user, name: "Hello again")

      get :index, params: { query: "again" }
      expect(assigns[:campaigns]).to eq([@second])
      expect(assigns[:current_query]).to eq("again")
      expect(session[:campaigns_current_query]).to eq("again")
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @campaigns = [create(:campaign, user: current_user)]
        get :index, params: { page: 42 }, xhr: true

        expect(assigns[:current_page].to_i).to eq(42)
        expect(assigns[:campaigns]).to eq([]) # page #42 should be empty if there's only one campaign ;-)
        expect(session[:campaigns_current_page].to_i).to eq(42)
        expect(response).to render_template("campaigns/index")
      end

      it "should pick up saved page number from session" do
        session[:campaigns_current_page] = 42
        @campaigns = [create(:campaign, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(42)
        expect(assigns[:campaigns]).to eq([])
        expect(response).to render_template("campaigns/index")
      end

      it "should reset current_page when query is altered" do
        session[:campaigns_current_page] = 42
        session[:campaigns_current_query] = "bill"
        @campaigns = [create(:campaign, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(1)
        expect(assigns[:campaigns]).to eq(@campaigns)
        expect(response).to render_template("campaigns/index")
      end
    end

    describe "with mime type of JSON" do
      it "should render all campaigns as JSON" do
        expect(@controller).to receive(:get_campaigns).and_return(@campaigns = [])
        expect(@campaigns).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render all campaigns as xml" do
        expect(@controller).to receive(:get_campaigns).and_return(@campaigns = [])
        expect(@campaigns).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        expect(response.body).to eq("generated XML")
      end
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml                                                   HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do
    describe "with mime type of HTML" do
      before(:each) do
        @campaign = create(:campaign, id: 42, user: current_user)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested campaign as @campaign and render [show] template" do
        get :show, params: { id: 42 }
        expect(assigns[:campaign]).to eq(@campaign)
        expect(assigns[:stage]).to eq(@stage)
        expect(assigns[:comment].attributes).to eq(@comment.attributes)
        expect(response).to render_template("campaigns/show")
      end

      it "should update an activity when viewing the campaign" do
        get :show, params: { id: @campaign.id }
        expect(@campaign.versions.last.event).to eq('view')
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested campaign as JSON" do
        @campaign = create(:campaign, id: 42, user: current_user)
        expect(Campaign).to receive(:find).and_return(@campaign)
        expect(@campaign).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render the requested campaign as XML" do
        @campaign = create(:campaign, id: 42, user: current_user)
        expect(Campaign).to receive(:find).and_return(@campaign)
        expect(@campaign).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, params: { id: 42 }
        expect(response.body).to eq("generated XML")
      end
    end

    describe "campaign got deleted or otherwise unavailable" do
      it "should redirect to campaign index if the campaign got deleted" do
        @campaign = create(:campaign, user: current_user)
        @campaign.destroy

        get :show, params: { id: @campaign.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should redirect to campaign index if the campaign is protected" do
        @campaign = create(:campaign, user: create(:user), access: "Private")

        get :show, params: { id: @campaign.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should return 404 (Not Found) JSON error" do
        @campaign = create(:campaign, user: current_user)
        @campaign.destroy
        request.env["HTTP_ACCEPT"] = "application/json"

        get :show, params: { id: @campaign.id }
        expect(response.code).to eq("404") # :not_found
      end

      it "should return 404 (Not Found) XML error" do
        @campaign = create(:campaign, user: current_user)
        @campaign.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, params: { id: @campaign.id }
        expect(response.code).to eq("404") # :not_found
      end
    end
  end

  # GET /campaigns/new
  # GET /campaigns/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do
    it "should expose a new campaign as @campaign" do
      @campaign = Campaign.new(user: current_user,
                               access: Setting.default_access)
      get :new, xhr: true
      expect(assigns[:campaign].attributes).to eq(@campaign.attributes)
      expect(response).to render_template("campaigns/new")
    end

    it "should create related object when necessary" do
      @lead = create(:lead, id: 42)

      get :new, params: { related: "lead_42" }, xhr: true
      expect(assigns[:lead]).to eq(@lead)
    end
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose the requested campaign as @campaign and render [edit] template" do
      @campaign = create(:campaign, id: 42, user: current_user)

      get :edit, params: { id: 42 }, xhr: true
      expect(assigns[:campaign]).to eq(@campaign)
      expect(response).to render_template("campaigns/edit")
    end

    it "should find previous campaign as necessary" do
      @campaign = create(:campaign, id: 42)
      @previous = create(:campaign, id: 99)

      get :edit, params: { id: 42, previous: 99 }, xhr: true
      expect(assigns[:campaign]).to eq(@campaign)
      expect(assigns[:previous]).to eq(@previous)
    end

    describe "(campaign got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the campaign got deleted" do
        @campaign = create(:campaign, user: current_user)
        @campaign.destroy

        get :edit, params: { id: @campaign.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the campaign is protected" do
        @private = create(:campaign, user: create(:user), access: "Private")

        get :edit, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous campaign got deleted or is otherwise unavailable)" do
      before(:each) do
        @campaign = create(:campaign, user: current_user)
        @previous = create(:campaign, user: create(:user))
      end

      it "should notify the view if previous campaign got deleted" do
        @previous.destroy

        get :edit, params: { id: @campaign.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("campaigns/edit")
      end

      it "should notify the view if previous campaign got protected" do
        @previous.update_attribute(:access, "Private")

        get :edit, params: { id: @campaign.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("campaigns/edit")
      end
    end
  end

  # POST /campaigns
  # POST /campaigns.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do
    describe "with valid params" do
      it "should expose a newly created campaign as @campaign and render [create] template" do
        @campaign = build(:campaign, name: "Hello", user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        post :create, params: { campaign: { name: "Hello" } }, xhr: true
        expect(assigns(:campaign)).to eq(@campaign)
        expect(response).to render_template("campaigns/create")
      end

      it "should get data to update campaign sidebar" do
        @campaign = build(:campaign, name: "Hello", user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        post :create, params: { campaign: { name: "Hello" } }, xhr: true
        expect(assigns[:campaign_status_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should reload campaigns to update pagination" do
        @campaign = build(:campaign, user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        post :create, params: { campaign: { name: "Hello" } }, xhr: true
        expect(assigns[:campaigns]).to eq([@campaign])
      end

      it "should add a new comment to the newly created campaign when specified" do
        @campaign = build(:campaign, name: "Hello world", user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        post :create, params: { campaign: { name: "Hello world" }, comment_body: "Awesome comment is awesome" }, xhr: true
        expect(@campaign.reload.comments.map(&:comment)).to include("Awesome comment is awesome")
      end
    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved campaign as @campaign and still render [create] template" do
        @campaign = build(:campaign, id: nil, name: nil, user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        post :create, params: { campaign: {} }, xhr: true
        expect(assigns(:campaign)).to eq(@campaign)
        expect(response).to render_template("campaigns/create")
      end
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update the requested campaign and render [update] template" do
        @campaign = create(:campaign, id: 42, name: "Bye")

        put :update, params: { id: 42, campaign: { name: "Hello" } }, xhr: true
        expect(@campaign.reload.name).to eq("Hello")
        expect(assigns(:campaign)).to eq(@campaign)
        expect(response).to render_template("campaigns/update")
      end

      it "should get data for campaigns sidebar when called from Campaigns index" do
        @campaign = create(:campaign, id: 42)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns"

        put :update, params: { id: 42, campaign: { name: "Hello" } }, xhr: true
        expect(assigns(:campaign)).to eq(@campaign)
        expect(assigns[:campaign_status_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should update campaign permissions when sharing with specific users" do
        @campaign = create(:campaign, id: 42, access: "Public")
        he  = create(:user, id: 7)
        she = create(:user, id: 8)

        put :update, params: { id: 42, campaign: { name: "Hello", access: "Shared", user_ids: %w[7 8] } }, xhr: true
        expect(assigns[:campaign].access).to eq("Shared")
        expect(assigns[:campaign].user_ids.sort).to eq([he.id, she.id])
      end

      describe "campaign got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the campaign got deleted" do
          @campaign = create(:campaign, user: current_user)
          @campaign.destroy

          put :update, params: { id: @campaign.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the campaign is protected" do
          @private = create(:campaign, user: create(:user), access: "Private")

          put :update, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "with invalid params" do
      it "should not update the requested campaign, but still expose it as @campaign and still render [update] template" do
        @campaign = create(:campaign, id: 42, name: "Hello", user: current_user)

        put :update, params: { id: 42, campaign: { name: nil } }, xhr: true
        expect(@campaign.reload.name).to eq("Hello")
        expect(assigns(:campaign)).to eq(@campaign)
        expect(response).to render_template("campaigns/update")
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      @campaign = create(:campaign, user: current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested campaign and render [destroy] template" do
        @another_campaign = create(:campaign, user: current_user)
        delete :destroy, params: { id: @campaign.id }, xhr: true

        expect(assigns[:campaigns]).to eq([@another_campaign])
        expect { Campaign.find(@campaign.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to render_template("campaigns/destroy")
      end

      it "should get data for campaigns sidebar" do
        delete :destroy, params: { id: @campaign.id }, xhr: true

        expect(assigns[:campaign_status_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should try previous page and render index action if current page has no campaigns" do
        session[:campaigns_current_page] = 42

        delete :destroy, params: { id: @campaign.id }, xhr: true
        expect(session[:campaigns_current_page]).to eq(41)
        expect(response).to render_template("campaigns/index")
      end

      it "should render index action when deleting last campaign" do
        session[:campaigns_current_page] = 1

        delete :destroy, params: { id: @campaign.id }, xhr: true
        expect(session[:campaigns_current_page]).to eq(1)
        expect(response).to render_template("campaigns/index")
      end

      describe "campaign got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the campaign got deleted" do
          @campaign = create(:campaign, user: current_user)
          @campaign.destroy

          delete :destroy, params: { id: @campaign.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the campaign is protected" do
          @private = create(:campaign, user: create(:user), access: "Private")

          delete :destroy, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Campaigns index when a campaign gets deleted from its landing page" do
        delete :destroy, params: { id: @campaign.id }

        expect(flash[:notice]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should redirect to campaign index with the flash message is the campaign got deleted" do
        @campaign = create(:campaign, user: current_user)
        @campaign.destroy

        delete :destroy, params: { id: @campaign.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should redirect to campaign index with the flash message if the campaign is protected" do
        @private = create(:campaign, user: create(:user), access: "Private")

        delete :destroy, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end
    end
  end

  # PUT /campaigns/1/attach
  # PUT /campaigns/1/attach.xml                                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = create(:campaign)
        @attachment = create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end

    describe "leads" do
      before do
        @model = create(:campaign)
        @attachment = create(:lead, campaign: nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = create(:campaign)
        @attachment = create(:opportunity, campaign: nil)
      end
      it_should_behave_like("attach")
    end
  end

  # PUT /campaigns/1/attach
  # PUT /campaigns/1/attach.xml                                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = create(:campaign)
        @attachment = create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end

    describe "leads" do
      before do
        @model = create(:campaign)
        @attachment = create(:lead, campaign: nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = create(:campaign)
        @attachment = create(:opportunity, campaign: nil)
      end
      it_should_behave_like("attach")
    end
  end

  # POST /campaigns/1/discard
  # POST /campaigns/1/discard.xml                                          AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST discard" do
    describe "tasks" do
      before do
        @model = create(:campaign)
        @attachment = create(:task, asset: @model)
      end
      it_should_behave_like("discard")
    end

    describe "leads" do
      before do
        @attachment = create(:lead)
        @model = create(:campaign)
        @model.leads << @attachment
      end
      it_should_behave_like("discard")
    end

    describe "opportunities" do
      before do
        @attachment = create(:opportunity)
        @model = create(:campaign)
        @model.opportunities << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /campaigns/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [create(:campaign, name: "Hello World", user: current_user)]
    end

    it_should_behave_like("auto complete")
  end

  # GET  /campaigns/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET redraw" do
    it "should save user selected campaign preference" do
      get :redraw, params: { per_page: 42, view: "brief", sort_by: "name" }, xhr: true
      expect(current_user.preference[:campaigns_per_page]).to eq(42)
      expect(current_user.preference[:campaigns_index_view]).to eq("brief")
      expect(current_user.preference[:campaigns_sort_by]).to eq("campaigns.name ASC")
    end

    it "should reset current page to 1" do
      get :redraw, params: { per_page: 42, view: "brief", sort_by: "name" }, xhr: true
      expect(session[:campaigns_current_page]).to eq(1)
    end

    it "should select @campaigns and render [index] template" do
      @campaigns = [
        create(:campaign, name: "A", user: current_user),
        create(:campaign, name: "B", user: current_user)
      ]

      get :redraw, params: { per_page: 1, sort_by: "name" }, xhr: true
      expect(assigns(:campaigns)).to eq([@campaigns.first])
      expect(response).to render_template("campaigns/index")
    end
  end

  # POST /campaigns/filter                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST filter" do
    it "should expose filtered campaigns as @campaigns and render [index] template" do
      session[:campaigns_filter] = "planned,started"
      @campaigns = [create(:campaign, status: "completed", user: current_user)]

      post :filter, params: { status: "completed" }, xhr: true
      expect(assigns(:campaigns)).to eq(@campaigns)
      expect(response).to render_template("campaigns/index")
    end

    it "should reset current page to 1" do
      @campaigns = []
      post :filter, params: { status: "completed" }, xhr: true

      expect(session[:campaigns_current_page]).to eq(1)
    end
  end
end
