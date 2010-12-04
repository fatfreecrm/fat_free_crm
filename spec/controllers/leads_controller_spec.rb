require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do

  before(:each) do
    require_user
    set_current_tab(:leads)
  end

  # GET /leads
  # GET /leads.xml                                                AJAX and HTML
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

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
      (assigns[:lead_status_total].keys.map(&:to_sym) - (@status << :all << :other)).should == []
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
      assigns[:leads].map(&:status).sort.should == %w(contacted new)
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @leads = [ Factory(:lead, :user => @current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:leads].should == [] # page #42 should be empty if there's only one lead ;-)
        session[:leads_current_page].to_i.should == 42
        response.should render_template("leads/index")
      end

      it "should pick up saved page number from session" do
        session[:leads_current_page] = 42
        @leads = [ Factory(:lead, :user => @current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:leads].should == []
        response.should render_template("leads/index")
      end
    end

    describe "with mime type of XML" do
      it "should render all leads as xml" do
        @leads = [ Factory(:lead, :user => @current_user).reload ]

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.body.should == @leads.to_xml
      end
    end

  end

  # GET /leads/1
  # GET /leads/1.xml                                                       HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before(:each) do
        @lead = Factory(:lead, :id => 42, :user => @current_user)
        @comment = Comment.new
      end

      it "should expose the requested lead as @lead and render [show] template" do
        get :show, :id => 42
        assigns[:lead].should == @lead
        assigns[:comment].attributes.should == @comment.attributes
        response.should render_template("leads/show")
      end

      it "should update an activity when viewing the lead" do
        Activity.should_receive(:log).with(@current_user, @lead, :viewed).once
        get :show, :id => @lead.id
      end
    end

    describe "with mime type of XML" do
      it "should render the requested lead as xml" do
        @lead = Factory(:lead, :id => 42, :user => @current_user)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @lead.reload.to_xml
      end
    end

    describe "lead got deleted or otherwise unavailable" do
      it "should redirect to lead index if the lead got deleted" do
        @lead = Factory(:lead, :user => @current_user)
        @lead.destroy

        get :show, :id => @lead.id
        flash[:warning].should_not == nil
        response.should redirect_to(leads_path)
      end

      it "should redirect to lead index if the lead is protected" do
        @private = Factory(:lead, :user => Factory(:user), :access => "Private")

        get :show, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(leads_path)
      end

      it "should return 404 (Not Found) XML error" do
        @lead = Factory(:lead, :user => @current_user)
        @lead.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, :id => @lead.id
        response.code.should == "404" # :not_found
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

    describe "(when creating related lead)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @campaign = Factory(:campaign)
        @campaign.destroy

        xhr :get, :new, :related => "campaign_#{@campaign.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/campaigns";'
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @campaign = Factory(:campaign, :access => "Private")

        xhr :get, :new, :related => "campaign_#{@campaign.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/campaigns";'
      end
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

    describe "lead got deleted or is otherwise unavailable" do
      it "should reload current page with the flash message if the lead got deleted" do
        @lead = Factory(:lead, :user => @current_user)
        @lead.destroy

        xhr :get, :edit, :id => @lead.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the lead is protected" do
        @private = Factory(:lead, :user => Factory(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous lead got deleted or is otherwise unavailable)" do
      before(:each) do
        @lead = Factory(:lead, :user => @current_user)
        @previous = Factory(:lead, :user => Factory(:user))
      end

      it "should notify the view if previous lead got deleted" do
        @previous.destroy

        xhr :get, :edit, :id => @lead.id, :previous => @previous.id
        flash[:warning].should == nil # no warning, just silently remove the div
        assigns[:previous].should == @previous.id
        response.should render_template("leads/edit")
      end

      it "should notify the view if previous lead got protected" do
        @previous.update_attribute(:access, "Private")

        xhr :get, :edit, :id => @lead.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("leads/edit")
      end
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
        assigns[:lead_status_total].should be_nil
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

        xhr :put, :create, :lead => { :first_name => "Billy", :last_name => "Bones", :access => "Campaign" }, :campaign => @campaign.id, :users => %w(7 8)
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
        assigns[:lead_status_total].should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should reload leads to update pagination if called from leads index" do
        @lead = Factory.build(:lead, :user => @current_user, :campaign => nil)
        Lead.stub!(:new).and_return(@lead)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        xhr :post, :create, :lead => { :first_name => "Billy", :last_name => "Bones" }, :users => %w(1 2 3)
        assigns[:leads].should == [ @lead ]
      end

      it "should reload lead campaign if called from campaign landing page" do
        @campaign = Factory(:campaign)
        @lead = Factory.build(:lead, :user => @current_user, :campaign => @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :put, :create, :lead => { :first_name => "Billy", :last_name => "Bones"}, :campaign => @campaign.id
        assigns[:campaign].should == @campaign
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
        @lead = Factory(:lead, :first_name => "Billy", :user => @current_user)

        xhr :put, :update, :id => @lead.id, :lead => { :first_name => "Bones" }
        @lead.reload.first_name.should == "Bones"
        assigns[:lead].should == @lead
        assigns[:lead_status_total].should == nil
        response.should render_template("leads/update")
      end

      it "should update lead status" do
        @lead = Factory(:lead, :status => "new", :user => @current_user)

        xhr :put, :update, :id => @lead.id, :lead => { :status => "rejected" }
        @lead.reload.status.should == "rejected"
      end

      it "should update lead source" do
        @lead = Factory(:lead, :source => "campaign", :user => @current_user)

        xhr :put, :update, :id => @lead.id, :lead => { :source => "cald_call" }
        @lead.reload.source.should == "cald_call"
      end

      it "should update lead campaign" do
        @campaigns = { :old => Factory(:campaign), :new => Factory(:campaign) }
        @lead = Factory(:lead, :campaign => @campaigns[:old])

        xhr :put, :update, :id => @lead.id, :lead => { :campaign_id => @campaigns[:new].id }
        @lead.reload.campaign.should == @campaigns[:new]
      end

      it "should decrement campaign leads count if campaign has been removed" do
        @campaign = Factory(:campaign)
        @lead = Factory(:lead, :campaign => @campaign)
        @count = @campaign.reload.leads_count

        xhr :put, :update, :id => @lead, :lead => { :campaign_id => nil }
        @lead.reload.campaign.should == nil
        @campaign.reload.leads_count.should == @count - 1
      end

      it "should increment campaign leads count if campaign has been assigned" do
        @campaign = Factory(:campaign)
        @lead = Factory(:lead, :campaign => nil)
        @count = @campaign.leads_count

        xhr :put, :update, :id => @lead, :lead => { :campaign_id => @campaign.id }
        @lead.reload.campaign.should == @campaign
        @campaign.reload.leads_count.should == @count + 1
      end

      it "should update both campaign leads counts if reassigned to a new campaign" do
        @campaigns = { :old => Factory(:campaign), :new => Factory(:campaign) }
        @lead = Factory(:lead, :campaign => @campaigns[:old])
        @counts = { :old => @campaigns[:old].reload.leads_count, :new => @campaigns[:new].leads_count }

        xhr :put, :update, :id => @lead, :lead => { :campaign_id => @campaigns[:new].id }
        @lead.reload.campaign.should == @campaigns[:new]
        @campaigns[:old].reload.leads_count.should == @counts[:old] - 1
        @campaigns[:new].reload.leads_count.should == @counts[:new] + 1
      end

      it "should update shared permissions for the campaign" do
        @lead = Factory(:lead, :user => @current_user)
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)

        xhr :put, :update, :id => @lead.id, :lead => { :access => "Shared" }, :users => %w(7 8)
        @lead.permissions.map(&:user_id).sort.should == [ 7, 8 ]
      end

      it "should get the data for leads sidebar when called from leads index" do
        @lead = Factory(:lead)

        request.env["HTTP_REFERER"] = "http://localhost/leads"
        xhr :put, :update, :id => @lead.id, :lead => { :first_name => "Billy" }
        assigns[:lead_status_total].should_not be_nil
        assigns[:lead_status_total].should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should reload lead campaign if called from campaign landing page" do
        @campaign = Factory(:campaign)
        @lead = Factory(:lead, :campaign => @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :put, :update, :id => @lead.id, :lead => { :first_name => "Hello" }
        assigns[:campaign].should == @campaign
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the lead got deleted" do
          @lead = Factory(:lead, :user => @current_user)
          @lead.destroy

          xhr :put, :update, :id => @lead.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the lead is protected" do
          @private = Factory(:lead, :user => Factory(:user), :access => "Private")

          xhr :put, :update, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
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
  # DELETE /leads/1.xml                                           AJAX and HTML
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do

    before(:each) do
      @lead = Factory(:lead, :user => @current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested lead and render [destroy] template" do
        xhr :delete, :destroy, :id => @lead.id

        assigns[:leads].should == nil # @lead got deleted
        lambda { Lead.find(@lead) }.should raise_error(ActiveRecord::RecordNotFound)
        response.should render_template("leads/destroy")
      end

      describe "when called from Leads index page" do
        before(:each) do
          request.env["HTTP_REFERER"] = "http://localhost/leads"
        end

        it "should get data for the sidebar" do
          @another_lead = Factory(:lead, :user => @current_user)

          xhr :delete, :destroy, :id => @lead.id
          assigns[:leads].should == [ @another_lead ] # @lead got deleted
          assigns[:lead_status_total].should_not be_nil
          assigns[:lead_status_total].should be_an_instance_of(HashWithIndifferentAccess)
          response.should render_template("leads/destroy")
        end

        it "should try previous page and render index action if current page has no leads" do
          session[:leads_current_page] = 42

          xhr :delete, :destroy, :id => @lead.id
          session[:leads_current_page].should == 41
          response.should render_template("leads/index")
        end

        it "should render index action when deleting last lead" do
          session[:leads_current_page] = 1

          xhr :delete, :destroy, :id => @lead.id
          session[:leads_current_page].should == 1
          response.should render_template("leads/index")
        end
      end

      describe "when called from campaign landing page" do
        before(:each) do
          @campaign = Factory(:campaign)
          @lead = Factory(:lead, :user => @current_user, :campaign => @campaign)
          request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        end

        it "should reset current page to 1" do
          xhr :delete, :destroy, :id => @lead.id
          session[:leads_current_page].should == 1
          response.should render_template("leads/destroy")
        end

        it "should reload campaiign to be able to refresh its summary" do
          xhr :delete, :destroy, :id => @lead.id
          assigns[:campaign].should == @campaign
          response.should render_template("leads/destroy")
        end
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the lead got deleted" do
          @lead = Factory(:lead, :user => @current_user)
          @lead.destroy

          xhr :delete, :destroy, :id => @lead.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the lead is protected" do
          @private = Factory(:lead, :user => Factory(:user), :access => "Private")

          xhr :delete, :destroy, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Leads index when a lead gets deleted from its landing page" do
        delete :destroy, :id => @lead.id
        flash[:notice].should_not == nil
        session[:leads_current_page].should == 1
        response.should redirect_to(leads_path)
      end

      it "should redirect to lead index with the flash message is the lead got deleted" do
        @lead = Factory(:lead, :user => @current_user)
        @lead.destroy

        delete :destroy, :id => @lead.id
        flash[:warning].should_not == nil
        response.should redirect_to(leads_path)
      end

      it "should redirect to lead index with the flash message if the lead is protected" do
        @private = Factory(:lead, :user => Factory(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(leads_path)
      end
    end
  end

  # GET /leads/1/convert
  # GET /leads/1/convert.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET convert" do

    it "should should collect necessary data and render [convert] template" do
      @campaign = Factory(:campaign, :user => @current_user)
      @lead = Factory(:lead, :user => @current_user, :campaign => @campaign, :source => "cold_call")
      @users = [ Factory(:user) ]
      @accounts = [ Factory(:account, :user => @current_user) ]
      @account = Account.new(:user => @current_user, :name => @lead.company, :access => "Lead")
      @opportunity = Opportunity.new(:user => @current_user, :access => "Lead", :stage => "prospecting", :campaign => @lead.campaign, :source => @lead.source)

      xhr :get, :convert, :id => @lead.id
      assigns[:lead].should == @lead
      assigns[:users].should == @users
      assigns[:accounts].should == @accounts
      assigns[:account].attributes.should == @account.attributes
      assigns[:opportunity].attributes.should == @opportunity.attributes
      assigns[:opportunity].campaign.should == @opportunity.campaign
      response.should render_template("leads/convert")
    end

    describe "(lead got deleted or is otherwise unavailable)" do
      it "should reload current page with the flash message if the lead got deleted" do
        @lead = Factory(:lead, :user => @current_user)
        @lead.destroy

        xhr :get, :convert, :id => @lead.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the lead is protected" do
        @private = Factory(:lead, :user => Factory(:user), :access => "Private")

        xhr :get, :convert, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous lead got deleted or is otherwise unavailable)" do
      before(:each) do
        @lead = Factory(:lead, :user => @current_user)
        @previous = Factory(:lead, :user => Factory(:user))
      end

      it "should notify the view if previous lead got deleted" do
        @previous.destroy

        xhr :get, :convert, :id => @lead.id, :previous => @previous.id
        flash[:warning].should == nil # no warning, just silently remove the div
        assigns[:previous].should == @previous.id
        response.should render_template("leads/convert")
      end

      it "should notify the view if previous lead got protected" do
        @previous.update_attribute(:access, "Private")

        xhr :get, :convert, :id => @lead.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("leads/convert")
      end
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
      @opportunity = Factory.build(:opportunity, :user => @current_user, :campaign => @lead.campaign,
                                   :account => @account)
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
      assigns[:stage].should be_instance_of(Array)
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

    it "should assign lead's campaign to the newly created opportunity" do
      @campaign = Factory(:campaign)
      @lead = Factory(:lead, :user => @current_user, :campaign => @campaign)

      xhr :put, :promote, :id => @lead.id, :account => { :name => "Hello" }, :opportunity => { :name => "Hello", :campaign_id => @campaign.id }
      assigns[:opportunity].campaign.should == @campaign
    end

    it "should assign lead's source to the newly created opportunity" do
      @lead = Factory(:lead, :user => @current_user, :source => "cold_call")

      xhr :put, :promote, :id => @lead.id, :account => { :name => "Hello" }, :opportunity => { :name => "Hello", :source => @lead.source }
      assigns[:opportunity].source.should == @lead.source
    end

    it "should get the data for leads sidebar when called from leads index" do
      @lead = Factory(:lead)
      request.env["HTTP_REFERER"] = "http://localhost/leads"

      xhr :put, :promote, :id => @lead.id, :account => { :name => "Hello" }, :opportunity => {}
      assigns[:lead_status_total].should_not be_nil
      assigns[:lead_status_total].should be_an_instance_of(HashWithIndifferentAccess)
    end

    it "should reload lead campaign if called from campaign landing page" do
      @campaign = Factory(:campaign)
      @lead = Factory(:lead, :campaign => @campaign)
      request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

      xhr :put, :promote, :id => @lead.id, :account => { :name => "Hello" }, :opportunity => {}
      assigns[:campaign].should == @campaign
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

    describe "lead got deleted or otherwise unavailable" do
      it "should reload current page with the flash message if the lead got deleted" do
        @lead = Factory(:lead, :user => @current_user)
        @lead.destroy

        xhr :put, :promote, :id => @lead.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the lead is protected" do
        @private = Factory(:lead, :user => Factory(:user), :access => "Private")

        xhr :put, :promote, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

  end

  # GET /leads/search/query                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET search" do
    before(:each) do
      @billy_bones   = Factory(:lead, :user => @current_user, :first_name => "Billy",   :last_name => "Bones")
      @captain_flint = Factory(:lead, :user => @current_user, :first_name => "Captain", :last_name => "Flint")
      @leads = [ @billy_bones, @captain_flint ]
    end

    it "should perform lookup using query string and redirect to index" do
      xhr :get, :search, :query => "bill"

      assigns[:leads].should == [ @billy_bones ]
      assigns[:current_query].should == "bill"
      session[:leads_current_query].should == "bill"
      response.should render_template("index")
    end

    describe "with mime type of XML" do
      it "should perform lookup using query string and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :search, :query => "bill?!"

        response.body.should == [ @billy_bones.reload ].to_xml
      end
    end
  end

  # PUT /leads/1/reject
  # PUT /leads/1/reject.xml                                       AJAX and HTML
  #----------------------------------------------------------------------------
  describe "responding to PUT reject" do

    before(:each) do
      @lead = Factory(:lead, :user => @current_user, :status => "new")
    end

    describe "AJAX request" do
      it "should reject the requested lead and render [reject] template" do
        xhr :put, :reject, :id => @lead.id

        assigns[:lead].should == @lead.reload
        @lead.status.should == "rejected"
        response.should render_template("leads/reject")
      end

      it "should get the data for leads sidebar when called from leads index" do
        request.env["HTTP_REFERER"] = "http://localhost/leads"
        xhr :put, :reject, :id => @lead.id
        assigns[:lead_status_total].should_not be_nil
        assigns[:lead_status_total].should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should reload lead campaign if called from campaign landing page" do
        @campaign = Factory(:campaign)
        @lead = Factory(:lead, :campaign => @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :put, :reject, :id => @lead.id
        assigns[:campaign].should == @campaign
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the lead got deleted" do
          @lead = Factory(:lead, :user => @current_user)
          @lead.destroy

          xhr :put, :reject, :id => @lead.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the lead is protected" do
          @private = Factory(:lead, :user => Factory(:user), :access => "Private")

          xhr :put, :reject, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Leads index when a lead gets rejected from its landing page" do
        put :reject, :id => @lead.id

        assigns[:lead].should == @lead.reload
        @lead.status.should == "rejected"
        flash[:notice].should_not == nil
        response.should redirect_to(leads_path)
      end

      describe "lead got deleted or otherwise unavailable" do
        it "should redirect to lead index if the lead got deleted" do
          @lead = Factory(:lead, :user => @current_user)
          @lead.destroy

          put :reject, :id => @lead.id
          flash[:warning].should_not == nil
          response.should redirect_to(leads_path)
        end

        it "should redirect to lead index if the lead is protected" do
          @private = Factory(:lead, :user => Factory(:user), :access => "Private")

          put :reject, :id => @private.id
          flash[:warning].should_not == nil
          response.should redirect_to(leads_path)
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
        @model = Factory(:lead)
        @attachment = Factory(:task, :asset => nil)
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
        @model = Factory(:lead)
        @attachment = Factory(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end
  end

  # POST /leads/1/discard
  # POST /leads/1/discard.xml                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST discard" do
    before(:each) do
      @attachment = Factory(:task, :assigned_to => @current_user)
      @model = Factory(:lead)
      @model.tasks << @attachment
    end

    it_should_behave_like("discard")
  end

  # POST /leads/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before(:each) do
      @auto_complete_matches = [ Factory(:lead, :first_name => "Hello", :last_name => "World", :user => @current_user) ]
    end

    it_should_behave_like("auto complete")
  end

  # GET /leads/options                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    it "should set current user preferences when showing options" do
      @per_page = Factory(:preference, :user => @current_user, :name => "leads_per_page", :value => Base64.encode64(Marshal.dump(42)))
      @outline  = Factory(:preference, :user => @current_user, :name => "leads_outline",  :value => Base64.encode64(Marshal.dump("option_long")))
      @sort_by  = Factory(:preference, :user => @current_user, :name => "leads_sort_by",  :value => Base64.encode64(Marshal.dump("leads.first_name ASC")))
      @naming   = Factory(:preference, :user => @current_user, :name => "leads_naming",   :value => Base64.encode64(Marshal.dump("option_after")))

      xhr :get, :options
      assigns[:per_page].should == 42
      assigns[:outline].should  == "option_long"
      assigns[:sort_by].should  == "leads.first_name ASC"
      assigns[:naming].should   == "option_after"
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, :cancel => "true"
      assigns[:per_page].should == nil
      assigns[:outline].should  == nil
      assigns[:sort_by].should  == nil
      assigns[:naming].should   == nil
    end
  end

  # POST /leads/redraw                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected lead preference" do
      xhr :post, :redraw, :per_page => 42, :outline => "long", :sort_by => "first_name", :naming => "after"
      @current_user.preference[:leads_per_page].should == 42
      @current_user.preference[:leads_outline].should  == "long"
      @current_user.preference[:leads_sort_by].should  == "leads.first_name ASC"
      @current_user.preference[:leads_naming].should   == "after"
    end

    it "should set similar options for Contacts" do
      xhr :post, :redraw, :sort_by => "first_name", :naming => "after"
      @current_user.pref[:contacts_sort_by].should == "contacts.first_name ASC"
      @current_user.pref[:contacts_naming].should == "after"
    end

    it "should reset current page to 1" do
      xhr :post, :redraw, :per_page => 42, :outline => "long", :sort_by => "first_name", :naming => "after"
      session[:leads_current_page].should == 1
    end

    it "should select @leads and render [index] template" do
      @leads = [
        Factory(:lead, :first_name => "Alice", :user => @current_user),
        Factory(:lead, :first_name => "Bobby", :user => @current_user)
      ]

      xhr :post, :redraw, :per_page => 1, :sort_by => "first_name"
      assigns(:leads).should == [ @leads.first ]
      response.should render_template("leads/index")
    end
  end

  # POST /leads/filter                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST filter" do

    it "should filter out leads as @leads and render :index action" do
      session[:filter_by_lead_status] = "contacted,rejected"

      @leads = [ Factory(:lead, :user => @current_user, :status => "new") ]
      xhr :post, :filter, :status => "new"
      assigns[:leads].should == @leads
      response.should be_a_success
      response.should render_template("leads/index")
    end

    it "should reset current page to 1" do
      @leads = []
      xhr :post, :filter, :status => "new"

      session[:leads_current_page].should == 1
    end

  end

end
