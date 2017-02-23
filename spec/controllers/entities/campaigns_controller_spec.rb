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
    require_user
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
      @campaigns = [FactoryGirl.create(:campaign, user: current_user)]

      get :index
      expect(assigns[:campaigns]).to eq(@campaigns)
      expect(response).to render_template("campaigns/index")
    end

    it "should collect the data for the opportunities sidebar" do
      @campaigns = [FactoryGirl.create(:campaign, user: current_user)]

      get :index
      expect(assigns[:campaign_status_total].keys.map(&:to_sym) - (@status << :all << :other)).to eq([])
    end

    it "should filter out campaigns by status" do
      controller.session[:campaigns_filter] = "planned,started"
      @campaigns = [
        FactoryGirl.create(:campaign, user: current_user, status: "started"),
        FactoryGirl.create(:campaign, user: current_user, status: "planned")
      ]

      # This one should be filtered out.
      FactoryGirl.create(:campaign, user: current_user, status: "completed")

      get :index
      # Note: can't compare campaigns directly because of BigDecimal objects.
      expect(assigns[:campaigns].size).to eq(2)
      expect(assigns[:campaigns].map(&:status).sort).to eq(%w(planned started))
    end

    it "should perform lookup using query string" do
      @first  = FactoryGirl.create(:campaign, user: current_user, name: "Hello, world!")
      @second = FactoryGirl.create(:campaign, user: current_user, name: "Hello again")

      get :index, query: "again"
      expect(assigns[:campaigns]).to eq([@second])
      expect(assigns[:current_query]).to eq("again")
      expect(session[:campaigns_current_query]).to eq("again")
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @campaigns = [FactoryGirl.create(:campaign, user: current_user)]
        xhr :get, :index, page: 42

        expect(assigns[:current_page].to_i).to eq(42)
        expect(assigns[:campaigns]).to eq([]) # page #42 should be empty if there's only one campaign ;-)
        expect(session[:campaigns_current_page].to_i).to eq(42)
        expect(response).to render_template("campaigns/index")
      end

      it "should pick up saved page number from session" do
        session[:campaigns_current_page] = 42
        @campaigns = [FactoryGirl.create(:campaign, user: current_user)]
        xhr :get, :index

        expect(assigns[:current_page]).to eq(42)
        expect(assigns[:campaigns]).to eq([])
        expect(response).to render_template("campaigns/index")
      end

      it "should reset current_page when query is altered" do
        session[:campaigns_current_page] = 42
        session[:campaigns_current_query] = "bill"
        @campaigns = [FactoryGirl.create(:campaign, user: current_user)]
        xhr :get, :index

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
        @campaign = FactoryGirl.create(:campaign, id: 42, user: current_user)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested campaign as @campaign and render [show] template" do
        get :show, id: 42
        expect(assigns[:campaign]).to eq(@campaign)
        expect(assigns[:stage]).to eq(@stage)
        expect(assigns[:comment].attributes).to eq(@comment.attributes)
        expect(response).to render_template("campaigns/show")
      end

      it "should update an activity when viewing the campaign" do
        get :show, id: @campaign.id
        expect(@campaign.versions.last.event).to eq('view')
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested campaign as JSON" do
        @campaign = FactoryGirl.create(:campaign, id: 42, user: current_user)
        expect(Campaign).to receive(:find).and_return(@campaign)
        expect(@campaign).to receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, id: 42
        expect(response.body).to eq("generated JSON")
      end
    end

    describe "with mime type of XML" do
      it "should render the requested campaign as XML" do
        @campaign = FactoryGirl.create(:campaign, id: 42, user: current_user)
        expect(Campaign).to receive(:find).and_return(@campaign)
        expect(@campaign).to receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, id: 42
        expect(response.body).to eq("generated XML")
      end
    end

    describe "campaign got deleted or otherwise unavailable" do
      it "should redirect to campaign index if the campaign got deleted" do
        @campaign = FactoryGirl.create(:campaign, user: current_user)
        @campaign.destroy

        get :show, id: @campaign.id
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should redirect to campaign index if the campaign is protected" do
        @campaign = FactoryGirl.create(:campaign, user: FactoryGirl.create(:user), access: "Private")

        get :show, id: @campaign.id
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should return 404 (Not Found) JSON error" do
        @campaign = FactoryGirl.create(:campaign, user: current_user)
        @campaign.destroy
        request.env["HTTP_ACCEPT"] = "application/json"

        get :show, id: @campaign.id
        expect(response.code).to eq("404") # :not_found
      end

      it "should return 404 (Not Found) XML error" do
        @campaign = FactoryGirl.create(:campaign, user: current_user)
        @campaign.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, id: @campaign.id
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
      xhr :get, :new
      expect(assigns[:campaign].attributes).to eq(@campaign.attributes)
      expect(response).to render_template("campaigns/new")
    end

    it "should create related object when necessary" do
      @lead = FactoryGirl.create(:lead, id: 42)

      xhr :get, :new, related: "lead_42"
      expect(assigns[:lead]).to eq(@lead)
    end
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do
    it "should expose the requested campaign as @campaign and render [edit] template" do
      @campaign = FactoryGirl.create(:campaign, id: 42, user: current_user)

      xhr :get, :edit, id: 42
      expect(assigns[:campaign]).to eq(@campaign)
      expect(response).to render_template("campaigns/edit")
    end

    it "should find previous campaign as necessary" do
      @campaign = FactoryGirl.create(:campaign, id: 42)
      @previous = FactoryGirl.create(:campaign, id: 99)

      xhr :get, :edit, id: 42, previous: 99
      expect(assigns[:campaign]).to eq(@campaign)
      expect(assigns[:previous]).to eq(@previous)
    end

    describe "(campaign got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the campaign got deleted" do
        @campaign = FactoryGirl.create(:campaign, user: current_user)
        @campaign.destroy

        xhr :get, :edit, id: @campaign.id
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end

      it "should reload current page with the flash message if the campaign is protected" do
        @private = FactoryGirl.create(:campaign, user: FactoryGirl.create(:user), access: "Private")

        xhr :get, :edit, id: @private.id
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq("window.location.reload();")
      end
    end

    describe "(previous campaign got deleted or is otherwise unavailable)" do
      before(:each) do
        @campaign = FactoryGirl.create(:campaign, user: current_user)
        @previous = FactoryGirl.create(:campaign, user: FactoryGirl.create(:user))
      end

      it "should notify the view if previous campaign got deleted" do
        @previous.destroy

        xhr :get, :edit, id: @campaign.id, previous: @previous.id
        expect(flash[:warning]).to eq(nil) # no warning, just silently remove the div
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template("campaigns/edit")
      end

      it "should notify the view if previous campaign got protected" do
        @previous.update_attribute(:access, "Private")

        xhr :get, :edit, id: @campaign.id, previous: @previous.id
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
        @campaign = FactoryGirl.build(:campaign, name: "Hello", user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        xhr :post, :create, campaign: { name: "Hello" }
        expect(assigns(:campaign)).to eq(@campaign)
        expect(response).to render_template("campaigns/create")
      end

      it "should get data to update campaign sidebar" do
        @campaign = FactoryGirl.build(:campaign, name: "Hello", user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        xhr :post, :create, campaign: { name: "Hello" }
        expect(assigns[:campaign_status_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should reload campaigns to update pagination" do
        @campaign = FactoryGirl.build(:campaign, user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        xhr :post, :create, campaign: { name: "Hello" }
        expect(assigns[:campaigns]).to eq([@campaign])
      end

      it "should add a new comment to the newly created campaign when specified" do
        @campaign = FactoryGirl.build(:campaign, name: "Hello world", user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        xhr :post, :create, campaign: { name: "Hello world" }, comment_body: "Awesome comment is awesome"
        expect(@campaign.reload.comments.map(&:comment)).to include("Awesome comment is awesome")
      end
    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved campaign as @campaign and still render [create] template" do
        @campaign = FactoryGirl.build(:campaign, id: nil, name: nil, user: current_user)
        allow(Campaign).to receive(:new).and_return(@campaign)

        xhr :post, :create, campaign: {}
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
        @campaign = FactoryGirl.create(:campaign, id: 42, name: "Bye")

        xhr :put, :update, id: 42, campaign: { name: "Hello" }
        expect(@campaign.reload.name).to eq("Hello")
        expect(assigns(:campaign)).to eq(@campaign)
        expect(response).to render_template("campaigns/update")
      end

      it "should get data for campaigns sidebar when called from Campaigns index" do
        @campaign = FactoryGirl.create(:campaign, id: 42)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns"

        xhr :put, :update, id: 42, campaign: { name: "Hello" }
        expect(assigns(:campaign)).to eq(@campaign)
        expect(assigns[:campaign_status_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should update campaign permissions when sharing with specific users" do
        @campaign = FactoryGirl.create(:campaign, id: 42, access: "Public")
        he  = FactoryGirl.create(:user, id: 7)
        she = FactoryGirl.create(:user, id: 8)

        xhr :put, :update, id: 42, campaign: { name: "Hello", access: "Shared", user_ids: %w(7 8) }
        expect(assigns[:campaign].access).to eq("Shared")
        expect(assigns[:campaign].user_ids.sort).to eq([he.id, she.id])
      end

      describe "campaign got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the campaign got deleted" do
          @campaign = FactoryGirl.create(:campaign, user: current_user)
          @campaign.destroy

          xhr :put, :update, id: @campaign.id
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the campaign is protected" do
          @private = FactoryGirl.create(:campaign, user: FactoryGirl.create(:user), access: "Private")

          xhr :put, :update, id: @private.id
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "with invalid params" do
      it "should not update the requested campaign, but still expose it as @campaign and still render [update] template" do
        @campaign = FactoryGirl.create(:campaign, id: 42, name: "Hello", user: current_user)

        xhr :put, :update, id: 42, campaign: { name: nil }
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
      @campaign = FactoryGirl.create(:campaign, user: current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested campaign and render [destroy] template" do
        @another_campaign = FactoryGirl.create(:campaign, user: current_user)
        xhr :delete, :destroy, id: @campaign.id

        expect(assigns[:campaigns]).to eq([@another_campaign])
        expect { Campaign.find(@campaign.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to render_template("campaigns/destroy")
      end

      it "should get data for campaigns sidebar" do
        xhr :delete, :destroy, id: @campaign.id

        expect(assigns[:campaign_status_total]).to be_instance_of(HashWithIndifferentAccess)
      end

      it "should try previous page and render index action if current page has no campaigns" do
        session[:campaigns_current_page] = 42

        xhr :delete, :destroy, id: @campaign.id
        expect(session[:campaigns_current_page]).to eq(41)
        expect(response).to render_template("campaigns/index")
      end

      it "should render index action when deleting last campaign" do
        session[:campaigns_current_page] = 1

        xhr :delete, :destroy, id: @campaign.id
        expect(session[:campaigns_current_page]).to eq(1)
        expect(response).to render_template("campaigns/index")
      end

      describe "campaign got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the campaign got deleted" do
          @campaign = FactoryGirl.create(:campaign, user: current_user)
          @campaign.destroy

          xhr :delete, :destroy, id: @campaign.id
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end

        it "should reload current page with the flash message if the campaign is protected" do
          @private = FactoryGirl.create(:campaign, user: FactoryGirl.create(:user), access: "Private")

          xhr :delete, :destroy, id: @private.id
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq("window.location.reload();")
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Campaigns index when a campaign gets deleted from its landing page" do
        delete :destroy, id: @campaign.id

        expect(flash[:notice]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should redirect to campaign index with the flash message is the campaign got deleted" do
        @campaign = FactoryGirl.create(:campaign, user: current_user)
        @campaign.destroy

        delete :destroy, id: @campaign.id
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(campaigns_path)
      end

      it "should redirect to campaign index with the flash message if the campaign is protected" do
        @private = FactoryGirl.create(:campaign, user: FactoryGirl.create(:user), access: "Private")

        delete :destroy, id: @private.id
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
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end

    describe "leads" do
      before do
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:lead, campaign: nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:opportunity, campaign: nil)
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
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:task, asset: nil)
      end
      it_should_behave_like("attach")
    end

    describe "leads" do
      before do
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:lead, campaign: nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:opportunity, campaign: nil)
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
        @model = FactoryGirl.create(:campaign)
        @attachment = FactoryGirl.create(:task, asset: @model)
      end
      it_should_behave_like("discard")
    end

    describe "leads" do
      before do
        @attachment = FactoryGirl.create(:lead)
        @model = FactoryGirl.create(:campaign)
        @model.leads << @attachment
      end
      it_should_behave_like("discard")
    end

    describe "opportunities" do
      before do
        @attachment = FactoryGirl.create(:opportunity)
        @model = FactoryGirl.create(:campaign)
        @model.opportunities << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /campaigns/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [FactoryGirl.create(:campaign, name: "Hello World", user: current_user)]
    end

    it_should_behave_like("auto complete")
  end

  # GET  /campaigns/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET redraw" do
    it "should save user selected campaign preference" do
      xhr :get, :redraw, per_page: 42, view: "brief", sort_by: "name"
      expect(current_user.preference[:campaigns_per_page]).to eq("42")
      expect(current_user.preference[:campaigns_index_view]).to eq("brief")
      expect(current_user.preference[:campaigns_sort_by]).to eq("campaigns.name ASC")
    end

    it "should reset current page to 1" do
      xhr :get, :redraw, per_page: 42, view: "brief", sort_by: "name"
      expect(session[:campaigns_current_page]).to eq(1)
    end

    it "should select @campaigns and render [index] template" do
      @campaigns = [
        FactoryGirl.create(:campaign, name: "A", user: current_user),
        FactoryGirl.create(:campaign, name: "B", user: current_user)
      ]

      xhr :get, :redraw, per_page: 1, sort_by: "name"
      expect(assigns(:campaigns)).to eq([@campaigns.first])
      expect(response).to render_template("campaigns/index")
    end
  end

  # POST /campaigns/filter                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST filter" do
    it "should expose filtered campaigns as @campaigns and render [index] template" do
      session[:campaigns_filter] = "planned,started"
      @campaigns = [FactoryGirl.create(:campaign, status: "completed", user: current_user)]

      xhr :post, :filter, status: "completed"
      expect(assigns(:campaigns)).to eq(@campaigns)
      expect(response).to render_template("campaigns/index")
    end

    it "should reset current page to 1" do
      @campaigns = []
      xhr :post, :filter, status: "completed"

      expect(session[:campaigns_current_page]).to eq(1)
    end
  end
end
