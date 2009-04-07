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
      (assigns[:campaign_status_total].keys - (@status.keys << :all << :other)).should == []
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
      assigns[:campaigns].map(&:status).should == %w(planned started)
    end

    describe "with mime type of xml" do

      it "should render all campaigns as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @campaigns = [ Factory(:campaign, :user => @current_user) ]

        get :index
        response.body.should == @campaigns.to_xml
      end

    end

  end

  # GET /campaigns/1
  # GET /campaigns/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    it "should expose the requested campaign as @campaign and render [show] template" do
      @campaign = Factory(:campaign, :id => 42, :user => @current_user)
      @stage = Setting.as_hash(:opportunity_stage)
      @comment = Comment.new

      get :show, :id => 42
      assigns[:campaign].should == @campaign
      assigns[:stage].should == @stage
      assigns[:comment].attributes.should == @comment.attributes
      response.should render_template("campaigns/show")
    end

    describe "with mime type of xml" do

      it "should render the requested campaign as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @campaign = Factory(:campaign, :id => 42, :user => @current_user)

        get :show, :id => 42
        response.body.should == @campaign.to_xml
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
        assigns[:campaign_status_total].should == nil
        response.should render_template("campaigns/create")
      end

      it "should get data to update campaign sidebar if called from campaigns index page" do
        @campaign = Factory.build(:campaign, :name => "Hello", :user => @current_user)
        Campaign.stub!(:new).and_return(@campaign)
        @users = [ Factory(:user) ]

        request.env["HTTP_REFERER"] = "http://localhost/campaigns"
        xhr :post, :create, :campaign => { :name => "Hello" }, :users => %w(1 2 3)
        assigns[:campaign_status_total].should be_instance_of(Hash)
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
        assigns[:campaign_status_total].should be_nil
        response.should render_template("campaigns/update")
      end

      it "should get data for campaigns sidebar if called from campaigns index page" do
        @campaign = Factory(:campaign, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns"
        xhr :put, :update, :id => 42, :campaign => { :name => "Hello" }, :users => []
        assigns(:campaign).should == @campaign
        assigns[:campaign_status_total].should be_instance_of(Hash)
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

    it "should destroy the requested campaign and render [destroy] template" do
      @campaign = Factory(:campaign, :id => 42)

      xhr :delete, :destroy, :id => 42
      lambda { @campaign.reload }.should raise_error(ActiveRecord::RecordNotFound)
      assigns[:campaign_status_total].should be_nil
      response.should render_template("campaigns/destroy")
    end

    it "should get data for campaigns sidebar if called from campaigns index page" do
      @campaign = Factory(:campaign, :id => 42)

      request.env["HTTP_REFERER"] = "http://localhost/campaigns"
      xhr :delete, :destroy, :id => 42
      assigns[:campaign_status_total].should be_instance_of(Hash)
    end

  end

  # Ajax request to filter out list of campaigns.                          AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET filter" do

    it "should expose filtered campaigns as @campaigns and render [filter] template" do
      session[:filter_by_campaign_status] = "planned,started"
      @campaigns = [ Factory(:campaign, :status => "completed", :user => @current_user) ]

      xhr :get, :filter, :status => "completed"
      assigns(:campaigns).should == @campaigns
      response.should render_template("campaigns/filter")
    end

    it "should redirect to Campaigns index when a campaign gets deleted from its landing page" do
      @campaign = Factory(:campaign)

      delete :destroy, :id => @campaign.id

      flash[:notice].should_not == nil
      response.should redirect_to(campaigns_path)
    end

  end

end
