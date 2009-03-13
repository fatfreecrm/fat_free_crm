require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do

  def get_data_for_sidebar
    @stage = Setting.as_hash(:opportunity_stage)
  end

  before(:each) do
    require_user
    set_current_tab(:opportunities)
  end

  # GET /opportunities
  # GET /opportunities.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    before(:each) do
      get_data_for_sidebar
    end

    it "should expose all opportunities as @opportunities and render [index] template" do
      @opportunities = [ Factory(:opportunity, :user => @current_user) ]

      get :index
      assigns[:opportunities].should == @opportunities
      response.should render_template("opportunities/index")
    end

    it "should expose the data for the opportunities sidebar" do
      get :index
      assigns[:stage].should == @stage
      (assigns[:opportunity_stage_total].keys - (@stage.keys << :all << :other)).should == []
    end

    it "should filter out opportunities by stage" do
      controller.session[:filter_by_opportunity_stage] = "prospecting,qualification"
      @opportunities = [
        Factory(:opportunity, :user => @current_user, :stage => "qualification"),
        Factory(:opportunity, :user => @current_user, :stage => "prospecting")
      ]
      # This one should be filtered out.
      Factory(:opportunity, :user => @current_user, :stage => "analysis")

      get :index
      # Note: can't compare opportunities directly because of BigDecimal objects.
      assigns[:opportunities].count.should == 2
      assigns[:opportunities].map(&:stage).should == %w(prospecting qualification)
    end

    describe "with mime type of xml" do

      it "should render all opportunities as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @opportunities = [ Factory(:opportunity, :user => @current_user) ]

        get :index
        response.body.should == @opportunities.to_xml
      end

    end

  end

  # GET /opportunities/1
  # GET /opportunities/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    it "should expose the requested opportunity as @opportunity and render [show] template" do
      @opportunity = Factory(:opportunity, :id => 42)
      @stage = Setting.as_hash(:opportunity_stage)
      @comment = Comment.new

      get :show, :id => 42
      assigns[:opportunity].should == @opportunity
      assigns[:stage].should == @stage
      assigns[:comment].attributes.should == @comment.attributes
    end

    describe "with mime type of xml" do

      it "should render the requested opportunity as xml" do
        @opportunity = Factory(:opportunity, :id => 42)
        @stage = Setting.as_hash(:opportunity_stage)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @opportunity.to_xml
      end

    end

  end

  # GET /opportunities/new
  # GET /opportunities/new.xml                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new opportunity as @opportunity and render [new] template" do
      @opportunity = Opportunity.new(:user => @current_user, :access => "Private", :stage => "prospecting")
      @account = Account.new(:user => @current_user, :access => "Private")
      @users = [ Factory(:user) ]
      @accounts = [ Factory(:account, :user => @current_user) ]

      xhr :get, :new
      assigns[:opportunity].attributes.should == @opportunity.attributes
      assigns[:account].attributes.should == @account.attributes
      assigns[:users].should == @users
      assigns[:accounts].should == @accounts
      response.should render_template("opportunities/new")
    end

    it "should created an instance of related object when necessary" do
      @contact = Factory(:contact, :id => 42)

      xhr :get, :new, :related => "contact_42"
      assigns[:contact].should == @contact
    end

  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested opportunity as @opportunity and render [edit] template" do
      # Note: campaign => nil makes sure campaign factory is not invoked which has a side
      # effect of creating an extra (campaign) user.
      @opportunity = Factory(:opportunity, :id => 42, :user => @current_user, :campaign => nil)
      @account  = Account.new
      @users = [ Factory(:user) ]
      @stage = Setting.as_hash(:opportunity_stage)
      @accounts = [ Factory(:account, :user => @current_user) ]

      xhr :get, :edit, :id => 42
      assigns[:opportunity].should == @opportunity
      assigns[:account].attributes.should == @account.attributes
      assigns[:accounts].should == @accounts
      assigns[:users].should == @users
      assigns[:stage].should == @stage
      assigns[:previous].should == nil
      response.should render_template("opportunities/edit")
    end

    it "should expose previous opportunity as @previous when necessary" do
      @opportunity = Factory(:opportunity, :id => 42)
      @previous = Factory(:opportunity, :id => 41)

      xhr :get, :edit, :id => 42, :previous => 41
      assigns[:previous].should == @previous
    end

  end

  # POST /opportunities
  # POST /opportunities.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created opportunity as @opportunity and render [create] template" do
        @opportunity = Factory.build(:opportunity, :name => "Hello world", :user => @current_user)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.as_hash(:opportunity_stage)

        xhr :post, :create, :opportunity => { :name => "Hello world" }, :account => { :name => "Hello again" }, :users => %w(1 2 3)
        assigns(:opportunity).should == @opportunity
        assigns(:stage).should == @stage
        assigns(:opportunity_stage_total).should == nil # No sidebar data unless called from /opportunies page.
        response.should render_template("opportunities/create")
      end

      it "should get sidebar data if request.referer =~ /opportunities$/" do
        @opportunity = Factory.build(:opportunity, :name => "Hello world", :user => @current_user)
        Opportunity.stub!(:new).and_return(@opportunity)

        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :post, :create, :opportunity => { :name => "Hello world" }, :account => { :name => "Hello again" }, :users => %w(1 2 3)
        assigns(:opportunity_stage_total).should_not be_empty
        assigns(:opportunity_stage_total).should be_an_instance_of(Hash)
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved opportunity as @opportunity with blank @account and render [create] template" do
        @opportunity = Factory.build(:opportunity, :name => nil, :campaign => nil, :user => @current_user)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.as_hash(:opportunity_stage)
        @users = [ Factory(:user) ]
        @account = Account.new(:user => @current_user)
        @accounts = [ Factory(:account, :user => @current_user) ]

        # Expect to redraw [create] form with blank account.
        xhr :post, :create, :opportunity => {}, :account => { :user_id => @current_user.id }
        assigns(:opportunity).should == @opportunity
        assigns(:users).should == @users
        assigns(:account).attributes.should == @account.attributes
        assigns(:accounts).should == @accounts
        response.should render_template("opportunities/create")
      end

      it "should expose a newly created but unsaved opportunity as @opportunity with existing @account and render [create] template" do
        @account = Factory(:account, :id => 42, :user => @current_user)
        @opportunity = Factory.build(:opportunity, :name => nil, :campaign => nil, :user => @current_user)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.as_hash(:opportunity_stage)
        @users = [ Factory(:user) ]

        # Expect to redraw [create] form with selected account.
        xhr :post, :create, :opportunity => {}, :account => { :id => 42, :user_id => @current_user.id }
        assigns(:opportunity).should == @opportunity
        assigns(:users).should == @users
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("opportunities/create")
      end

    end

  end

  # PUT /opportunities/1
  # PUT /opportunities/1.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested opportunity and render [update] template" do
        @opportunity = Factory(:opportunity, :id => 42)
        @stage = Setting.as_hash(:opportunity_stage)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }
        @opportunity.reload.name.should == "Hello world"
        assigns(:opportunity).should == @opportunity
        assigns(:stage).should == @stage
        assigns(:opportunity_stage_total).should == nil
        response.should render_template("opportunities/update")
      end

      it "should get sidebar data if request.referer =~ /\/opportunities$/" do
        @oppportunity = Factory(:opportunity, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }
        assigns(:opportunity_stage_total).should_not be_empty
        assigns(:opportunity_stage_total).should be_an_instance_of(Hash)
      end

    end

    describe "with invalid params" do

      it "should not update the requested opportunity but still expose it as @opportunity, and render [update] template" do
        @opportunity = Factory(:opportunity, :id => 42, :name => "Hello people")

        xhr :put, :update, :id => 42, :opportunity => { :name => nil }
        @opportunity.reload.name.should == "Hello people"
        assigns(:opportunity).should == @opportunity
        response.should render_template("opportunities/update")
      end

    end

  end

  # DELETE /opportunities/1
  # DELETE /opportunities/1.xml                                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do

    it "should destroy the requested opportunity" do
      @opportunity = Factory(:opportunity, :id => 42)

      xhr :delete, :destroy, :id => 42
      lambda { @opportunity.reload }.should raise_error(ActiveRecord::RecordNotFound)
      assigns(:opportunity_stage_total).should == nil
      response.should render_template("opportunities/destroy")
    end

    it "should get sidebar data if request.referer =~ /\/opportunities$/" do
      @oppportunity = Factory(:opportunity, :id => 42)

      request.env["HTTP_REFERER"] = "http://localhost/opportunities"
      xhr :delete, :destroy, :id => 42
      assigns(:opportunity_stage_total).should_not be_empty
      assigns(:opportunity_stage_total).should be_an_instance_of(Hash)
    end

  end

  # Ajax request to filter out list of opportunities.                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET filter" do

    it "should update page[:opportunities] using inline RJS" do
      session[:filter_by_opportunity_stage] = params[:stage]
      @opportunities = [ Factory(:opportunity, :user => @current_user) ]
      @stage = Setting.as_hash(:opportunity_stage)

      xhr :get, :filter, :stage => "prospecting"
      assigns(:opportunity).should == @opportunity
      assigns[:stage].should == @stage
      response.should render_template("opportunities/filter")
    end

  end

end
