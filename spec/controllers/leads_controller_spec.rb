require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do

  def get_data_for_sidebar
    @lead_status_total = Setting.lead_status
  end

  before(:each) do
    require_user
    set_current_tab(:leads)
  end

  # GET /leads
  # GET /leads.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    before(:each) do
      get_data_for_sidebar
    end

    it "should expose all leads as @leads and render [index] template" do
      @leads = [ Factory(:lead, :user => @current_user) ]

      get :index
      assigns[:leads].should == @leads
      response.should render_template("leads/index")
    end

    it "should collect the data for the leads sidebar" do
      @leads = [ Factory(:lead, :user => @current_user) ]
      @status = Setting.lead_status

      get :index
      (assigns[:lead_status_total].keys - (@status.keys << :all << :other)).should == []
    end

    it "should filter out leads by status" do
      controller.session[:filter_by_lead_status] = "new,contacted"
      @leads = [
        Factory(:lead, :status => "new", :user => @current_user),
        Factory(:lead, :status => "contacted", :user => @current_user)
      ]

      # This one should be filtered out.
      Factory(:lead, :status => "rejected", :user => @current_user)

      get :index
      # Note: can't compare campaigns directly because of BigDecimals.
      assigns[:leads].size.should == 2
      assigns[:leads].map(&:status).should == %w(contacted new)
    end

    describe "with mime type of xml" do

      it "should render all leads as xml" do
        @leads = [ Factory(:lead, :user => @current_user) ]

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.body.should == @leads.to_xml
      end

    end

  end

  # GET /leads/1
  # GET /leads/1.xml
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    it "should expose the requested lead as @lead and render [show] template" do
      @lead = Factory(:lead, :id => 42, :user => @current_user)
      @comment = Comment.new

      get :show, :id => 42
      assigns[:lead].should == @lead
      assigns[:comment].attributes.should == @comment.attributes
      response.should render_template("leads/show")
    end

    describe "with mime type of xml" do

      it "should render the requested lead as xml" do
        @lead = Factory(:lead, :id => 42, :user => @current_user)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @lead.to_xml
      end

    end

  end

  # GET /leads/new
  # GET /leads/new.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new lead as @lead and render [new] template" do
      @lead = Factory.build(:lead, :user => @current_user, :campaign => nil)
      Lead.stub!(:new).and_return(@lead)
      @users = [ Factory(:user) ]
      @campaigns = [ Factory(:campaign, :user => @current_user) ]

      xhr :get, :new
      assigns[:lead].attributes.should == @lead.attributes
      assigns[:users].should == @users
      assigns[:campaigns].should == @campaigns
      response.should render_template("leads/new")
    end

    it "should create related object when necessary" do
      @campaign = Factory(:campaign, :id => 123)

      xhr :get, :new, :related => "campaign_123"
      assigns[:campaign].should == @campaign
    end

  end

  # GET /leads/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested lead as @lead and render [edit] template" do
      @lead = Factory(:lead, :id => 42, :user => @current_user, :campaign => nil)
      @users = [ Factory(:user) ]
      @campaigns = [ Factory(:campaign, :user => @current_user) ]

      xhr :get, :edit, :id => 42
      assigns[:lead].should == @lead
      assigns[:users].should == @users
      assigns[:campaigns].should == @campaigns
      response.should render_template("leads/edit")
    end

    it "should find previous lead when necessary" do
      @lead = Factory(:lead, :id => 42)
      @previous = Factory(:lead, :id => 321)

      xhr :get, :edit, :id => 42, :previous => 321
      assigns[:previous].should == @previous
    end

  end

  # POST /leads
  # POST /leads.xml                                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created lead as @lead and render [create] template" do
        @lead = Factory.build(:lead, :user => @current_user, :campaign => nil)
        Lead.stub!(:new).and_return(@lead)
        @users = [ Factory(:user) ]
        @campaigns = [ Factory(:campaign, :user => @current_user) ]

        xhr :post, :create, :lead => { :first_name => "Billy", :last_name => "Bones" }, :users => %w(1 2 3)
        assigns(:lead).should == @lead
        assigns(:users).should == @users
        assigns(:campaigns).should == @campaigns
        assigns[:lead_status_total].should == nil
        response.should render_template("leads/create")
      end

      it "should copy selected campaign permissions unless asked otherwise" do
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)
        @campaign = Factory.build(:campaign, :access => "Shared")
        @campaign.permissions << Factory.build(:permission, :user => he,  :asset => @campaign)
        @campaign.permissions << Factory.build(:permission, :user => she, :asset => @campaign)
        @campaign.save

        @lead = Factory.build(:lead, :campaign => @campaign, :user => @current_user, :access => "Shared")
        Lead.stub!(:new).and_return(@lead)

        xhr :put, :create, :lead => { :first_name => "Billy", :last_name => "Bones", :campaign_id => @campaign.id, :access => "Campaign" }, :users => %w(7 8)
        @lead.reload.access.should == "Shared"
        @lead.permissions.map(&:user_id).sort.should == [ 7, 8 ]
        @lead.permissions.map(&:asset_id).should == [ @lead.id, @lead.id ]
        @lead.permissions.map(&:asset_type).should == %w(Lead Lead)
      end

      it "should get the data to update leads sidebar if called from leads index" do
        @lead = Factory.build(:lead, :user => @current_user, :campaign => nil)
        Lead.stub!(:new).and_return(@lead)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        xhr :post, :create, :lead => { :first_name => "Billy", :last_name => "Bones" }, :users => %w(1 2 3)
        assigns[:lead_status_total].should be_an_instance_of(Hash)
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved lead as @lead and still render [create] template" do
        @lead = Factory.build(:lead, :user => @current_user, :first_name => nil, :campaign => nil)
        Lead.stub!(:new).and_return(@lead)
        @users = [ Factory(:user) ]
        @campaigns = [ Factory(:campaign, :user => @current_user) ]

        xhr :post, :create, :lead => { :first_name => nil }, :users => nil
        assigns(:lead).should == @lead
        assigns(:users).should == @users
        assigns(:campaigns).should == @campaigns
        assigns[:lead_status_total].should == nil
        response.should render_template("leads/create")
      end

    end

  end

  # PUT /leads/1
  # PUT /leads/1.xml
  #----------------------------------------------------------------------------
  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested lead, expose it as @lead, and render [update] template" do
        @lead = Factory(:lead, :id => 42, :first_name => "Billy", :user => @current_user)

        xhr :put, :update, :id => 42, :lead => { :first_name => "Bones" }
        @lead.reload.first_name.should == "Bones"
        assigns[:lead].should == @lead
        assigns[:lead_status_total].should == nil
        response.should render_template("leads/update")
      end

      it "should update lead status" do
        @lead = Factory(:lead, :id => 42, :status => "new", :user => @current_user)

        xhr :put, :update, :id => 42, :lead => { :status => "rejected" }
        @lead.reload.status.should == "rejected"
      end

      it "should update lead source" do
        @lead = Factory(:lead, :id => 42, :source => "campaign", :user => @current_user)

        xhr :put, :update, :id => 42, :lead => { :source => "cald_call" }
        @lead.reload.source.should == "cald_call"
      end

      it "should update lead campaign" do
        old_campaign = Factory(:campaign)
        new_campaign = Factory(:campaign)
        @lead = Factory(:lead, :id => 42, :campaign => old_campaign, :user => @current_user)

        xhr :put, :update, :id => 42, :lead => { :campaign_id => new_campaign.id }
        @lead.reload.campaign.should == new_campaign
      end

      it "should update shared permissions for the campaign" do
        @lead = Factory(:lead, :user => @current_user)
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)

        xhr :put, :update, :id => @lead.id, :lead => { :access => "Shared" }, :users => %w(7 8)
        @lead.permissions.map(&:user_id).sort.should == [ 7, 8 ]
      end

      it "should get the data for leads sidebar when called from leads index" do
        @lead = Factory(:lead, :id => 42, :user => @current_user)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        xhr :put, :update, :id => 42, :lead => { :first_name => "Billy" }
        assigns[:lead_status_total].should_not be_nil
        assigns[:lead_status_total].should be_an_instance_of(Hash)
      end

    end

    describe "with invalid params" do

      it "should not update the lead, but still expose it as @lead and render [update] template" do
        @lead = Factory(:lead, :id => 42, :user => @current_user, :campaign => nil)
        @users = [ Factory(:user) ]
        @campaigns = [ Factory(:campaign, :user => @current_user) ]

        xhr :put, :update, :id => 42, :lead => { :first_name => nil }
        assigns[:lead].should == @lead
        assigns[:users].should == @users
        assigns[:campaigns].should == @campaigns
        response.should render_template("leads/update")
      end

    end

  end

  # DELETE /leads/1
  # DELETE /leads/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do

    it "should destroy the requested lead and render [destroy] template" do
      @lead = Factory(:lead, :id => 42, :user => @current_user)

      xhr :delete, :destroy, :id => 42
      assigns[:lead_status_total].should be_nil
    end

    it "should get the data for leads sidebar if called from leads index" do
      @lead = Factory(:lead, :id => 42, :user => @current_user)
      request.env["HTTP_REFERER"] = "http://localhost/leads"

      xhr :delete, :destroy, :id => 42
      assigns[:lead].should == @lead
      assigns[:lead_status_total].should_not be_nil
      assigns[:lead_status_total].should be_an_instance_of(Hash)
      response.should render_template("leads/destroy")
    end

  end

  # GET /leads/1/convert
  # GET /leads/1/convert.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET convert" do

    it "should should collect necessary data and render [convert] template" do
      @lead = Factory(:lead, :id => 42, :user => @current_user, :campaign => nil)
      @users = [ Factory(:user) ]
      @accounts = [ Factory(:account, :user => @current_user) ]
      @account = Account.new(:user => @current_user, :name => @lead.company, :access => "Lead")
      @opportunity = Opportunity.new(:user => @current_user, :access => "Lead", :stage => "prospecting")

      xhr :get, :convert, :id => 42
      assigns[:lead].should == @lead
      assigns[:users].should == @users
      assigns[:accounts].should == @accounts
      assigns[:account].attributes.should == @account.attributes
      assigns[:opportunity].attributes.should == @opportunity.attributes
      response.should render_template("leads/convert")
    end

  end

  # PUT /leads/1/promote
  # PUT /leads/1/promote.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT promote" do

    it "on success: should change lead's status to [converted] and render [promote] template" do
      @lead = Factory(:lead, :id => 42, :user => @current_user, :campaign => nil)
      @users = [ Factory(:user) ]
      @account = Factory(:account, :id => 123, :user => @current_user)
      @opportunity = Factory.build(:opportunity, :user => @current_user, :campaign => @lead.campaign)
      Opportunity.stub!(:new).and_return(@opportunity)
      @contact = Factory.build(:contact, :user => @current_user, :lead => @lead)
      Contact.stub!(:new).and_return(@contact)

      xhr :put, :promote, :id => 42, :account => { :id => 123 }, :opportunity => { :name => "Hello" }
      @lead.reload.status.should == "converted"
      assigns[:lead].should == @lead
      assigns[:users].should == @users
      assigns[:account].should == @account
      assigns[:accounts].should == [ @account ]
      assigns[:opportunity].should == @opportunity
      assigns[:contact].should == @contact
      response.should render_template("leads/promote")
    end

    it "should copy lead permissions to newly created account and opportunity when asked so" do
      he  = Factory(:user, :id => 7)
      she = Factory(:user, :id => 8)
      @lead = Factory.build(:lead, :access => "Shared")
      @lead.permissions << Factory.build(:permission, :user => he,  :asset => @lead)
      @lead.permissions << Factory.build(:permission, :user => she, :asset => @lead)
      @lead.save
      @account = Factory.build(:account, :user => @current_user, :access => "Shared")
      @account.permissions << Factory(:permission, :user => he,  :asset => @account)
      @account.permissions << Factory(:permission, :user => she, :asset => @account)
      @account.stub!(:new).and_return(@account)
      @opportunity = Factory.build(:opportunity, :user => @current_user, :access => "Shared")
      @opportunity.permissions << Factory(:permission, :user => he,  :asset => @opportunity)
      @opportunity.permissions << Factory(:permission, :user => she, :asset => @opportunity)
      @opportunity.stub!(:new).and_return(@opportunity)

      xhr :put, :promote, :id => @lead.id, :access => "Lead", :account => { :name => "Hello", :access => "Lead", :user_id => @current_user.id }, :opportunity => { :name => "World", :access => "Lead", :user_id => @current_user.id }
      @account.access.should == "Shared"
      @account.permissions.map(&:user_id).sort.should == [ 7, 8 ]
      @account.permissions.map(&:asset_id).should == [ @account.id, @account.id ]
      @account.permissions.map(&:asset_type).should == %w(Account Account)
      @opportunity.access.should == "Shared"
      @opportunity.permissions.map(&:user_id).sort.should == [ 7, 8 ]
      @opportunity.permissions.map(&:asset_id).should == [ @opportunity.id, @opportunity.id ]
      @opportunity.permissions.map(&:asset_type).should == %w(Opportunity Opportunity)
    end

    it "on failure: should not change lead's status and still render [promote] template" do
      @lead = Factory(:lead, :id => 42, :user => @current_user, :status => "new")
      @users = [ Factory(:user) ]
      @account = Factory(:account, :id => 123, :user => @current_user)
      @contact = Factory.build(:contact, :first_name => nil) # make it fail
      Contact.stub!(:new).and_return(@contact)

      xhr :put, :promote, :id => 42, :account => { :id => 123 }
      @lead.reload.status.should == "new"
      response.should render_template("leads/promote")
    end

  end

  # Ajax request to filter out list of leads.
  #----------------------------------------------------------------------------
  describe "responding to GET filter" do

    it "should filter out leads as @leads and render [filter] template" do
      session[:filter_by_lead_status] = "contacted,rejected"

      @leads = [ Factory(:lead, :user => @current_user, :status => "new") ]
      xhr :get, :filter, :status => "new"
      assigns[:leads].should == @leads
      response.should render_template("leads/filter")
    end

  end

end
