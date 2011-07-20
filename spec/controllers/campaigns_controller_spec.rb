require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CampaignsController do

  def get_data_for_sidebar
    @status = Setting.campaign_status
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
      @campaigns = [ Factory(:campaign, :user => @current_user) ]

      get :index
      assigns[:campaigns].should == @campaigns
      response.should render_template("campaigns/index")
    end

    it "should collect the data for the opportunities sidebar" do
      @campaigns = [ Factory(:campaign, :user => @current_user) ]

      get :index
      (assigns[:campaign_status_total].keys.map(&:to_sym) - (@status << :all << :other)).should == []
    end

    it "should filter out campaigns by status" do
      controller.session[:filter_by_campaign_status] = "planned,started"
      @campaigns = [
        Factory(:campaign, :user => @current_user, :status => "started"),
        Factory(:campaign, :user => @current_user, :status => "planned")
      ]

      # This one should be filtered out.
      Factory(:campaign, :user => @current_user, :status => "completed")

      get :index
      # Note: can't compare campaigns directly because of BigDecimal objects.
      assigns[:campaigns].size.should == 2
      assigns[:campaigns].map(&:status).sort.should == %w(planned started)
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @campaigns = [ Factory(:campaign, :user => @current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:campaigns].should == [] # page #42 should be empty if there's only one campaign ;-)
        session[:campaigns_current_page].to_i.should == 42
        response.should render_template("campaigns/index")
      end

      it "should pick up saved page number from session" do
        session[:campaigns_current_page] = 42
        @campaigns = [ Factory(:campaign, :user => @current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:campaigns].should == []
        response.should render_template("campaigns/index")
      end
    end

    describe "with mime type of XML" do
      it "should render all campaigns as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @campaigns = [ Factory(:campaign, :user => @current_user).reload ]

        get :index
        response.body.should == @campaigns.to_xml
      end
    end

  end

  # GET /campaigns/1
  # GET /campaigns/1.xml                                                   HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before(:each) do
        @campaign = Factory(:campaign, :id => 42, :user => @current_user)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested campaign as @campaign and render [show] template" do
        get :show, :id => 42
        assigns[:campaign].should == @campaign
        assigns[:stage].should == @stage
        assigns[:comment].attributes.should == @comment.attributes
        response.should render_template("campaigns/show")
      end

      it "should update an activity when viewing the campaign" do
        Activity.should_receive(:log).with(@current_user, @campaign, :viewed).once
        get :show, :id => @campaign.id
      end
    end

    describe "with mime type of XML" do
      it "should render the requested campaign as XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @campaign = Factory(:campaign, :id => 42, :user => @current_user)

        get :show, :id => 42
        response.body.should == @campaign.reload.to_xml
      end
    end

    describe "campaign got deleted or otherwise unavailable" do
      it "should redirect to campaign index if the campaign got deleted" do
        @campaign = Factory(:campaign, :user => @current_user)
        @campaign.destroy

        get :show, :id => @campaign.id
        flash[:warning].should_not == nil
        response.should redirect_to(campaigns_path)
      end

      it "should redirect to campaign index if the campaign is protected" do
        @campaign = Factory(:campaign, :user => Factory(:user), :access => "Private")

        get :show, :id => @campaign.id
        flash[:warning].should_not == nil
        response.should redirect_to(campaigns_path)
      end

      it "should return 404 (Not Found) XML error" do
        @campaign = Factory(:campaign, :user => @current_user)
        @campaign.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, :id => @campaign.id
        response.code.should == "404" # :not_found
      end
    end

  end

  # GET /campaigns/new
  # GET /campaigns/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new campaign as @campaign" do
      @campaign = Campaign.new(:user => @current_user)
      @users = [ Factory(:user) ]

      xhr :get, :new
      assigns[:campaign].attributes.should == @campaign.attributes
      assigns[:users].should == @users
      response.should render_template("campaigns/new")
    end

    it "should create related object when necessary" do
      @lead = Factory(:lead, :id => 42)

      xhr :get, :new, :related => "lead_42"
      assigns[:lead].should == @lead
    end

  end

  # # GET /campaigns/1/edit                                                  AJAX
  # #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested campaign as @campaign and render [edit] template" do
      @campaign = Factory(:campaign, :id => 42, :user => @current_user)
      @users = [ Factory(:user) ]

      xhr :get, :edit, :id => 42
      assigns[:campaign].should == @campaign
      assigns[:users].should == @users
      response.should render_template("campaigns/edit")
    end

    it "should find previous campaign as necessary" do
      @campaign = Factory(:campaign, :id => 42)
      @previous = Factory(:campaign, :id => 99)

      xhr :get, :edit, :id => 42, :previous => 99
      assigns[:campaign].should == @campaign
      assigns[:previous].should == @previous
    end

    describe "(campaign got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the campaign got deleted" do
        @campaign = Factory(:campaign, :user => @current_user)
        @campaign.destroy

        xhr :get, :edit, :id => @campaign.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the campaign is protected" do
        @private = Factory(:campaign, :user => Factory(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous campaign got deleted or is otherwise unavailable)" do
      before(:each) do
        @campaign = Factory(:campaign, :user => @current_user)
        @previous = Factory(:campaign, :user => Factory(:user))
      end

      it "should notify the view if previous campaign got deleted" do
        @previous.destroy

        xhr :get, :edit, :id => @campaign.id, :previous => @previous.id
        flash[:warning].should == nil # no warning, just silently remove the div
        assigns[:previous].should == @previous.id
        response.should render_template("campaigns/edit")
      end

      it "should notify the view if previous campaign got protected" do
        @previous.update_attribute(:access, "Private")

        xhr :get, :edit, :id => @campaign.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("campaigns/edit")
      end
    end

  end

  # POST /campaigns
  # POST /campaigns.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created campaign as @campaign and render [create] template" do
        @campaign = Factory.build(:campaign, :name => "Hello", :user => @current_user)
        Campaign.stub!(:new).and_return(@campaign)
        @users = [ Factory(:user) ]

        xhr :post, :create, :campaign => { :name => "Hello" }, :users => %w(1 2 3)
        assigns(:campaign).should == @campaign
        assigns(:users).should == @users
        response.should render_template("campaigns/create")
      end

      it "should get data to update campaign sidebar" do
        @campaign = Factory.build(:campaign, :name => "Hello", :user => @current_user)
        Campaign.stub!(:new).and_return(@campaign)
        @users = [ Factory(:user) ]

        xhr :post, :create, :campaign => { :name => "Hello" }, :users => %w(1 2 3)
        assigns[:campaign_status_total].should be_instance_of(HashWithIndifferentAccess)
      end

      it "should reload campaigns to update pagination" do
        @campaign = Factory.build(:campaign, :user => @current_user)
        Campaign.stub!(:new).and_return(@campaign)

        xhr :post, :create, :campaign => { :name => "Hello" }, :users => %w(1 2 3)
        assigns[:campaigns].should == [ @campaign ]
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved campaign as @campaign and still render [create] template" do
        @campaign = Factory.build(:campaign, :id => nil, :name => nil, :user => @current_user)
        Campaign.stub!(:new).and_return(@campaign)
        @users = [ Factory(:user) ]

        xhr :post, :create, :campaign => nil, :users => %w(1 2 3)
        assigns(:campaign).should == @campaign
        assigns(:users).should == @users
        response.should render_template("campaigns/create")
      end

    end

  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested campaign and render [update] template" do
        @campaign = Factory(:campaign, :id => 42, :name => "Bye")

        xhr :put, :update, :id => 42, :campaign => { :name => "Hello" }, :users => []
        @campaign.reload.name.should == "Hello"
        assigns(:campaign).should == @campaign
        response.should render_template("campaigns/update")
      end

      it "should get data for campaigns sidebar when called from Campaigns index" do
        @campaign = Factory(:campaign, :id => 42)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns"

        xhr :put, :update, :id => 42, :campaign => { :name => "Hello" }, :users => []
        assigns(:campaign).should == @campaign
        assigns[:campaign_status_total].should be_instance_of(HashWithIndifferentAccess)
      end

      it "should update campaign permissions when sharing with specific users" do
        @campaign = Factory(:campaign, :id => 42, :access => "Public")
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)

        xhr :put, :update, :id => 42, :campaign => { :name => "Hello", :access => "Shared" }, :users => %w(7 8)
        @campaign.reload.access.should == "Shared"
        @campaign.permissions.map(&:user_id).sort.should == [ 7, 8 ]
        assigns[:campaign].should == @campaign
      end

      describe "campaign got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the campaign got deleted" do
          @campaign = Factory(:campaign, :user => @current_user)
          @campaign.destroy

          xhr :put, :update, :id => @campaign.id, :users => []
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the campaign is protected" do
          @private = Factory(:campaign, :user => Factory(:user), :access => "Private")

          xhr :put, :update, :id => @private.id, :users => []
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end

    end

    describe "with invalid params" do

      it "should not update the requested campaign, but still expose it as @campaign and still render [update] template" do
        @campaign = Factory(:campaign, :id => 42, :name => "Hello", :user => @current_user)
        @users = [ Factory(:user) ]

        xhr :put, :update, :id => 42, :campaign => { :name => nil }
        @campaign.reload.name.should == "Hello"
        assigns(:campaign).should == @campaign
        assigns(:users).should == @users
        response.should render_template("campaigns/update")
      end

    end

  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before(:each) do
      @campaign = Factory(:campaign, :user => @current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested campaign and render [destroy] template" do
        @another_campaign = Factory(:campaign, :user => @current_user)
        xhr :delete, :destroy, :id => @campaign.id

        assigns[:campaigns].should == [ @another_campaign ]
        lambda { Campaign.find(@campaign) }.should raise_error(ActiveRecord::RecordNotFound)
        response.should render_template("campaigns/destroy")
      end

      it "should get data for campaigns sidebar" do
        xhr :delete, :destroy, :id => @campaign.id

        assigns[:campaign_status_total].should be_instance_of(HashWithIndifferentAccess)
      end

      it "should try previous page and render index action if current page has no campaigns" do
        session[:campaigns_current_page] = 42

        xhr :delete, :destroy, :id => @campaign.id
        session[:campaigns_current_page].should == 41
        response.should render_template("campaigns/index")
      end

      it "should render index action when deleting last campaign" do
        session[:campaigns_current_page] = 1

        xhr :delete, :destroy, :id => @campaign.id
        session[:campaigns_current_page].should == 1
        response.should render_template("campaigns/index")
      end

      describe "campaign got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the campaign got deleted" do
          @campaign = Factory(:campaign, :user => @current_user)
          @campaign.destroy

          xhr :delete, :destroy, :id => @campaign.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the campaign is protected" do
          @private = Factory(:campaign, :user => Factory(:user), :access => "Private")

          xhr :delete, :destroy, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Campaigns index when a campaign gets deleted from its landing page" do
        delete :destroy, :id => @campaign.id

        flash[:notice].should_not == nil
        response.should redirect_to(campaigns_path)
      end

      it "should redirect to campaign index with the flash message is the campaign got deleted" do
        @campaign = Factory(:campaign, :user => @current_user)
        @campaign.destroy

        delete :destroy, :id => @campaign.id
        flash[:warning].should_not == nil
        response.should redirect_to(campaigns_path)
      end

      it "should redirect to campaign index with the flash message if the campaign is protected" do
        @private = Factory(:campaign, :user => Factory(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(campaigns_path)
      end
    end

  end

  # GET /campaigns/search/query                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET search" do
    before(:each) do
      @first  = Factory(:campaign, :user => @current_user, :name => "Hello, world!")
      @second = Factory(:campaign, :user => @current_user, :name => "Hello again")
      @campaigns = [ @first, @second ]
    end

    it "should perform lookup using query string and redirect to index" do
      xhr :get, :search, :query => "again"

      assigns[:campaigns].should == [ @second ]
      assigns[:current_query].should == "again"
      session[:campaigns_current_query].should == "again"
      response.should render_template("index")
    end

    describe "with mime type of XML" do
      it "should perform lookup using query string and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :search, :query => "again?!"

        response.body.should == [ @second.reload ].to_xml
      end
    end
  end

  # PUT /campaigns/1/attach
  # PUT /campaigns/1/attach.xml                                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = Factory(:campaign)
        @attachment = Factory(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "leads" do
      before do
        @model = Factory(:campaign)
        @attachment = Factory(:lead, :campaign => nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = Factory(:campaign)
        @attachment = Factory(:opportunity, :campaign => nil)
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
        @model = Factory(:campaign)
        @attachment = Factory(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "leads" do
      before do
        @model = Factory(:campaign)
        @attachment = Factory(:lead, :campaign => nil)
      end
      it_should_behave_like("attach")
    end

    describe "opportunities" do
      before do
        @model = Factory(:campaign)
        @attachment = Factory(:opportunity, :campaign => nil)
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
        @model = Factory(:campaign)
        @attachment = Factory(:task, :asset => @model)
      end
      it_should_behave_like("discard")
    end

    describe "leads" do
      before do
        @attachment = Factory(:lead)
        @model = Factory(:campaign)
        @model.leads << @attachment
      end
      it_should_behave_like("discard")
    end

    describe "opportunities" do
      before do
        @attachment = Factory(:opportunity)
        @model = Factory(:campaign)
        @model.opportunities << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /campaigns/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [ Factory(:campaign, :name => "Hello World", :user => @current_user) ]
    end

    it_should_behave_like("auto complete")
  end

  # GET /campaigns/options                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    it "should set current user preferences when showing options" do
      @per_page = Factory(:preference, :user => @current_user, :name => "campaigns_per_page", :value => Base64.encode64(Marshal.dump(42)))
      @outline  = Factory(:preference, :user => @current_user, :name => "campaigns_outline",  :value => Base64.encode64(Marshal.dump("option_long")))
      @sort_by  = Factory(:preference, :user => @current_user, :name => "campaigns_sort_by",  :value => Base64.encode64(Marshal.dump("campaigns.name ASC")))

      xhr :get, :options
      assigns[:per_page].should == 42
      assigns[:outline].should  == "option_long"
      assigns[:sort_by].should  == "campaigns.name ASC"
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, :cancel => "true"
      assigns[:per_page].should == nil
      assigns[:outline].should  == nil
      assigns[:sort_by].should  == nil
    end
  end

  # POST /campaigns/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected campaign preference" do
      xhr :post, :redraw, :per_page => 42, :outline => "brief", :sort_by => "name"
      @current_user.preference[:campaigns_per_page].should == 42
      @current_user.preference[:campaigns_outline].should  == "brief"
      @current_user.preference[:campaigns_sort_by].should  == "campaigns.name ASC"
    end

    it "should reset current page to 1" do
      xhr :post, :redraw, :per_page => 42, :outline => "brief", :sort_by => "name"
      session[:campaigns_current_page].should == 1
    end

    it "should select @campaigns and render [index] template" do
      @campaigns = [
        Factory(:campaign, :name => "A", :user => @current_user),
        Factory(:campaign, :name => "B", :user => @current_user)
      ]

      xhr :post, :redraw, :per_page => 1, :sort_by => "name"
      assigns(:campaigns).should == [ @campaigns.first ]
      response.should render_template("campaigns/index")
    end
  end

  # POST /campaigns/filter                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST filter" do

    it "should expose filtered campaigns as @campaigns and render [index] template" do
      session[:filter_by_campaign_status] = "planned,started"
      @campaigns = [ Factory(:campaign, :status => "completed", :user => @current_user) ]

      xhr :post, :filter, :status => "completed"
      assigns(:campaigns).should == @campaigns
      response.should render_template("campaigns/index")
    end

    it "should reset current page to 1" do
      @campaigns = []
      xhr :post, :filter, :status => "completed"

      session[:campaigns_current_page].should == 1
    end

  end

end
