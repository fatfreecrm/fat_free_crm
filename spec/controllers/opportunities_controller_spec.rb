require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do

  def get_data_for_sidebar
    @stage = Setting.unroll(:opportunity_stage)
  end

  before do
    require_user
    set_current_tab(:opportunities)
  end

  # GET /opportunities
  # GET /opportunities.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do

    before do
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
      (assigns[:opportunity_stage_total].keys.map(&:to_sym) - (@stage.map(&:last) << :all << :other)).should == []
    end

    it "should filter out opportunities by stage" do
      controller.session[:filter_by_opportunity_stage] = "prospecting,negotiation"
      @opportunities = [
        Factory(:opportunity, :user => @current_user, :stage => "negotiation"),
        Factory(:opportunity, :user => @current_user, :stage => "prospecting")
      ]
      # This one should be filtered out.
      Factory(:opportunity, :user => @current_user, :stage => "analysis")

      get :index
      # Note: can't compare opportunities directly because of BigDecimal objects.
      assigns[:opportunities].size.should == 2
      assigns[:opportunities].map(&:stage).sort.should == %w(negotiation prospecting)
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @opportunities = [ Factory(:opportunity, :user => @current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:opportunities].should == [] # page #42 should be empty if there's only one opportunity ;-)
        session[:opportunities_current_page].to_i.should == 42
        response.should render_template("opportunities/index")
      end

      it "should pick up saved page number from session" do
        session[:opportunities_current_page] = 42
        @opportunities = [ Factory(:opportunity, :user => @current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:opportunities].should == []
        response.should render_template("opportunities/index")
      end
    end

    describe "with mime type of XML" do
      it "should render all opportunities as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @opportunities = [ Factory(:opportunity, :user => @current_user).reload ]

        get :index
        response.body.should == @opportunities.to_xml
      end
    end

  end

  # GET /opportunities/1
  # GET /opportunities/1.xml                                               HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before do
        @opportunity = Factory(:opportunity, :id => 42)
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
      end

      it "should expose the requested opportunity as @opportunity and render [show] template" do
        get :show, :id => 42
        assigns[:opportunity].should == @opportunity
        assigns[:stage].should == @stage
        assigns[:comment].attributes.should == @comment.attributes
        response.should render_template("opportunities/show")
      end

      it "should update an activity when viewing the opportunity" do
        Activity.should_receive(:log).with(@current_user, @opportunity, :viewed).once
        get :show, :id => @opportunity.id
      end
    end

    describe "with mime type of XML" do
      it "should render the requested opportunity as xml" do
        @opportunity = Factory(:opportunity, :id => 42)
        @stage = Setting.unroll(:opportunity_stage)

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @opportunity.reload.to_xml
      end
    end

    describe "opportunity got deleted or otherwise unavailable" do
      it "should redirect to opportunity index if the opportunity got deleted" do
        @opportunity = Factory(:opportunity, :user => @current_user)
        @opportunity.destroy

        get :show, :id => @opportunity.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should redirect to opportunity index if the opportunity is protected" do
        @private = Factory(:opportunity, :user => Factory(:user), :access => "Private")

        get :show, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should return 404 (Not Found) XML error" do
        @opportunity = Factory(:opportunity, :user => @current_user)
        @opportunity.destroy
        request.env["HTTP_ACCEPT"] = "application/xml"

        get :show, :id => @opportunity.id
        response.code.should == "404" # :not_found
      end
    end

  end

  # GET /opportunities/new
  # GET /opportunities/new.xml                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    it "should expose a new opportunity as @opportunity and render [new] template" do
      @opportunity = Opportunity.new(:user => @current_user, :access => Setting.default_access, :stage => "prospecting")
      @account = Account.new(:user => @current_user, :access => Setting.default_access)
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

    describe "(when creating related opportunity)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = Factory(:account)
        @account.destroy

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = Factory(:account, :access => "Private")

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end
    end

  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    it "should expose the requested opportunity as @opportunity and render [edit] template" do
      # Note: campaign => nil makes sure campaign factory is not invoked which has a side
      # effect of creating an extra (campaign) user.
      @account = Factory(:account, :user => @current_user)
      @opportunity = Factory(:opportunity, :id => 42, :user => @current_user, :campaign => nil,
                             :account => @account)
      @users = [ Factory(:user) ]
      @stage = Setting.unroll(:opportunity_stage)
      @accounts = [ @account ]

      xhr :get, :edit, :id => 42
      @opportunity.reload
      assigns[:opportunity].should == @opportunity
      assigns[:account].attributes.should == @opportunity.account.attributes
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

    describe "opportunity got deleted or is otherwise unavailable" do
      it "should reload current page with the flash message if the opportunity got deleted" do
        @opportunity = Factory(:opportunity, :user => @current_user)
        @opportunity.destroy

        xhr :get, :edit, :id => @opportunity.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the opportunity is protected" do
        @private = Factory(:opportunity, :user => Factory(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous opportunity got deleted or is otherwise unavailable)" do
      before do
        @opportunity = Factory(:opportunity, :user => @current_user)
        @previous = Factory(:opportunity, :user => Factory(:user))
      end

      it "should notify the view if previous opportunity got deleted" do
        @previous.destroy

        xhr :get, :edit, :id => @opportunity.id, :previous => @previous.id
        flash[:warning].should == nil # no warning, just silently remove the div
        assigns[:previous].should == @previous.id
        response.should render_template("opportunities/edit")
      end

      it "should notify the view if previous opportunity got protected" do
        @previous.update_attribute(:access, "Private")

        xhr :get, :edit, :id => @opportunity.id, :previous => @previous.id
        flash[:warning].should == nil
        assigns[:previous].should == @previous.id
        response.should render_template("opportunities/edit")
      end
    end
  end

  # POST /opportunities
  # POST /opportunities.xml                                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do

      before do
        @opportunity = Factory.build(:opportunity, :user => @current_user)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.unroll(:opportunity_stage)
      end

      it "should expose a newly created opportunity as @opportunity and render [create] template" do
        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :name => "Hello again" }, :users => %w(1 2 3)
        assigns(:opportunity).should == @opportunity
        assigns(:stage).should == @stage
        assigns(:opportunity_stage_total).should be_nil
        response.should render_template("opportunities/create")
      end

      it "should get sidebar data if called from opportunities index" do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :name => "Hello again" }, :users => %w(1 2 3)
        assigns(:opportunity_stage_total).should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should find related account if called from account landing page" do
        @account = Factory(:account, :user => @current_user)
        request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :id => @account.id }, :users => %w(1 2 3)
        assigns(:account).should == @account
      end

      it "should find related campaign if called from campaign landing page" do
        @campaign = Factory(:campaign, :user => @current_user)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

        xhr :post, :create, :opportunity => { :name => "Hello" }, :campaign => @campaign.id, :account => { :name => "Hello again" }, :users => %w(1 2 3)
        assigns(:campaign).should == @campaign
      end

      it "should reload opportunities to update pagination if called from opportunities index" do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :name => "Hello again" }, :users => %w(1 2 3)
        assigns[:opportunities].should == [ @opportunity ]
      end

      it "should associate opportunity with the campaign when called from campaign landing page" do
        @campaign = Factory(:campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :campaign => @campaign.id, :account => { :name => "Test Account" }, :users => []
        assigns(:opportunity).should == @opportunity
        assigns(:campaign).should == @campaign
        @opportunity.campaign.should == @campaign
      end

      it "should associate opportunity with the contact when called from contact landing page" do
        @contact = Factory(:contact, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/contacts/42"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :contact => 42, :account => { :name => "Hello again" }, :users => []
        assigns(:opportunity).should == @opportunity
        @opportunity.contacts.should include(@contact)
        @contact.opportunities.should include(@opportunity)
      end

      it "should create new account and associate it with the opportunity" do
        xhr :put, :create, :opportunity => { :name => "Hello" }, :account => { :name => "new account" }
        assigns(:opportunity).should == @opportunity
        @opportunity.account.name.should == "new account"
      end

      it "should associate opportunity with the existing account" do
        @account = Factory(:account, :id => 42)

        xhr :post, :create, :opportunity => { :name => "Hello world" }, :account => { :id => 42 }, :users => []
        assigns(:opportunity).should == @opportunity
        @opportunity.account.should == @account
        @account.opportunities.should include(@opportunity)
      end

      it "should update related campaign revenue if won" do
        @campaign = Factory(:campaign, :revenue => 0)
        @opportunity = Factory.build(:opportunity, :user => @current_user, :stage => "won", :amount => 1100, :discount => 100)
        Opportunity.stub!(:new).and_return(@opportunity)

        xhr :post, :create, :opportunity => { :name => "Hello world" }, :campaign => @campaign.id, :account => { :name => "Test Account" }
        assigns(:opportunity).should == @opportunity
        @opportunity.campaign.should == @campaign.reload
        @campaign.revenue.to_i.should == 1000 # 1000 - 100 discount.
      end
    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved opportunity as @opportunity with blank @account and render [create] template" do
        @account = Account.new(:user => @current_user)
        @opportunity = Factory.build(:opportunity, :name => nil, :campaign => nil, :user => @current_user,
                                     :account => @account)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.unroll(:opportunity_stage)
        @users = [ Factory(:user) ]
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
        @opportunity = Factory.build(:opportunity, :name => nil, :campaign => nil, :user => @current_user,
                                     :account => @account)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.unroll(:opportunity_stage)
        @users = [ Factory(:user) ]

        # Expect to redraw [create] form with selected account.
        xhr :post, :create, :opportunity => {}, :account => { :id => 42, :user_id => @current_user.id }
        assigns(:opportunity).should == @opportunity
        assigns(:users).should == @users
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("opportunities/create")
      end

      it "should preserve the campaign when called from campaign landing page" do
        @campaign = Factory(:campaign, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/42"
        xhr :post, :create, :opportunity => { :name => nil }, :campaign => 42, :account => { :name => "Test Account" }, :users => []
        assigns(:campaign).should == @campaign
        response.should render_template("opportunities/create")
      end

      it "should preserve the contact when called from contact landing page" do
        @contact = Factory(:contact, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/contacts/42"
        xhr :post, :create, :opportunity => { :name => nil }, :contact => 42, :account => { :name => "Test Account" }, :users => []
        assigns(:contact).should == @contact
        response.should render_template("opportunities/create")
      end

    end

  end

  # PUT /opportunities/1
  # PUT /opportunities/1.xml                                               AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT update" do

    describe "with valid params" do

      it "should update the requested opportunity, expose it as @opportunity, and render [update] template" do
        @opportunity = Factory(:opportunity, :id => 42)
        @stage = Setting.unroll(:opportunity_stage)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }, :account => { :name => "Test Account" }, :users => %w(1 2 3)
        @opportunity.reload.name.should == "Hello world"
        assigns(:opportunity).should == @opportunity
        assigns(:stage).should == @stage
        assigns(:opportunity_stage_total).should == nil
        response.should render_template("opportunities/update")
      end

      it "should get sidebar data if called from opportunities index" do
        @oppportunity = Factory(:opportunity, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }, :account => { :name => "Test Account" }
        assigns(:opportunity_stage_total).should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should find related account if called from account landing page" do
        @account = Factory(:account, :user => @current_user)
        @oppportunity = Factory(:opportunity, :id => 42, :account => @account)
        request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }
        assigns(:account).should == @account
      end

      it "should remove related account if blank :account param is given" do
        @account = Factory(:account, :user => @current_user)
        @oppportunity = Factory(:opportunity, :id => 42, :account => @account)
        request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }, :account => {}
        assigns(:account).should == nil
      end

      it "should find related campaign if called from campaign landing page" do
        @campaign = Factory(:campaign, :user => @current_user)
        @opportunity = Factory(:opportunity, :id => 42, :user => @current_user)
        @campaign.opportunities << @opportunity
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world", :campaign_id => @campaign.id }, :account => {}
        assigns(:campaign).should == @campaign
      end

      it "should be able to create an account and associate it with updated opportunity" do
        @opportunity = Factory(:opportunity, :id => 42)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello" }, :account => { :name => "new account" }
        assigns[:opportunity].should == @opportunity
        @opportunity.reload
        @opportunity.account.should_not be_nil
        @opportunity.account.name.should == "new account"
      end

      it "should be able to create an account and associate it with updated opportunity" do
        @old_account = Factory(:account, :id => 111)
        @new_account = Factory(:account, :id => 999)
        @opportunity = Factory(:opportunity, :id => 42, :account => @old_account)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello" }, :account => { :id => 999 }
        @opportunity.reload
        assigns[:opportunity].should == @opportunity
        @opportunity.account.should == @new_account
      end

      it "should update opportunity permissions when sharing with specific users" do
        @opportunity = Factory(:opportunity, :id => 42, :access => "Public")
        he  = Factory(:user, :id => 7)
        she = Factory(:user, :id => 8)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello", :access => "Shared" }, :users => %w(7 8), :account => { :name => "Test Account" }
        @opportunity.reload.access.should == "Shared"
        @opportunity.permissions.map(&:user_id).sort.should == [ 7, 8 ]
        assigns[:opportunity].should == @opportunity
      end

      it "should reload opportunity campaign if called from campaign landing page" do
        @campaign = Factory(:campaign)
        @opportunity = Factory(:opportunity, :campaign => @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :put, :update, :id => @opportunity.id, :opportunity => { :name => "Hello" }, :account => { :name => "Test Account" }
        assigns[:campaign].should == @campaign
      end

      describe "updating campaign revenue (same campaign)" do
        it "should add to actual revenue when opportunity is closed/won" do
          @campaign = Factory(:campaign, :revenue => 1000)
          @opportunity = Factory(:opportunity, :campaign => @campaign, :stage => nil, :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "won" }, :account => { :name => "Test Account" }
          @campaign.reload.revenue.to_i.should == 2000 # 1000 -> 2000
        end

        it "should substract from actual revenue when opportunity is no longer closed/won" do
          @campaign = Factory(:campaign, :revenue => 1000)
          @opportunity = Factory(:opportunity, :campaign => @campaign, :stage => "won", :amount => 1100, :discount => 100)
          # @campaign.revenue is now $2000 since we created winning opportunity.

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => nil }, :account => { :name => "Test Account" }
          @campaign.reload.revenue.to_i.should == 1000 # Should be adjusted back to $1000.
        end

        it "should not update actual revenue when opportunity is not closed/won" do
          @campaign = Factory(:campaign, :revenue => 1000)
          @opportunity = Factory(:opportunity, :campaign => @campaign, :stage => nil, :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "lost" }, :account => { :name => "Test Account" }
          @campaign.reload.revenue.to_i.should == 1000 # Stays the same.
        end
      end

      describe "updating campaign revenue (diferent campaigns)" do
        it "should update newly assigned campaign when opportunity is closed/won" do
          @campaigns = { :old => Factory(:campaign, :revenue => 1000), :new => Factory(:campaign, :revenue => 1000) }
          @opportunity = Factory(:opportunity, :campaign => @campaigns[:old], :stage => nil, :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "won", :campaign_id => @campaigns[:new].id }, :account => { :name => "Test Account" }

          @campaigns[:old].reload.revenue.to_i.should == 1000 # Stays the same.
          @campaigns[:new].reload.revenue.to_i.should == 2000 # 1000 -> 2000
        end

        it "should update old campaign when opportunity is no longer closed/won" do
          @campaigns = { :old => Factory(:campaign, :revenue => 1000), :new => Factory(:campaign, :revenue => 1000) }
          @opportunity = Factory(:opportunity, :campaign => @campaigns[:old], :stage => "won", :amount => 1100, :discount => 100)
          # @campaign.revenue is now $2000 since we created winning opportunity.

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => nil, :campaign_id => @campaigns[:new].id }, :account => { :name => "Test Account" }
          @campaigns[:old].reload.revenue.to_i.should == 1000 # Should be adjusted back to $1000.
          @campaigns[:new].reload.revenue.to_i.should == 1000 # Stays the same.
        end

        it "should not update campaigns when opportunity is not closed/won" do
          @campaigns = { :old => Factory(:campaign, :revenue => 1000), :new => Factory(:campaign, :revenue => 1000) }
          @opportunity = Factory(:opportunity, :campaign => @campaigns[:old], :stage => nil, :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "lost", :campaign_id => @campaigns[:new].id }, :account => { :name => "Test Account" }
          @campaigns[:old].reload.revenue.to_i.should == 1000 # Stays the same.
          @campaigns[:new].reload.revenue.to_i.should == 1000 # Stays the same.
        end
      end

      describe "opportunity got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the opportunity got deleted" do
          @opportunity = Factory(:opportunity, :user => @current_user)
          @opportunity.destroy

          xhr :put, :update, :id => @opportunity.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the opportunity is protected" do
          @private = Factory(:opportunity, :user => Factory(:user), :access => "Private")

          xhr :put, :update, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "with invalid params" do

      it "should not update the requested opportunity but still expose it as @opportunity, and render [update] template" do
        @opportunity = Factory(:opportunity, :id => 42, :name => "Hello people")

        xhr :put, :update, :id => 42, :opportunity => { :name => nil }, :account => { :name => "Test Account" }
        @opportunity.reload.name.should == "Hello people"
        assigns(:opportunity).should == @opportunity
        assigns(:opportunity_stage_total).should == nil
        response.should render_template("opportunities/update")
      end

      it "should expose existing account as @account if selected" do
        @account = Factory(:account, :id => 99)
        @opportunity = Factory(:opportunity, :id => 42)
        Factory(:account_opportunity, :account => @account, :opportunity => @opportunity)

        xhr :put, :update, :id => 42, :opportunity => { :name => nil }, :account => { :id => 99 }
        assigns(:account).should == @account
      end

    end

  end

  # DELETE /opportunities/1
  # DELETE /opportunities/1.xml                                            AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    before do
      @opportunity = Factory(:opportunity, :user => @current_user)
    end

    describe "AJAX request" do
      it "should destroy the requested opportunity and render [destroy] template" do
        xhr :delete, :destroy, :id => @opportunity.id

        lambda { Opportunity.find(@opportunity) }.should raise_error(ActiveRecord::RecordNotFound)
        assigns(:opportunity_stage_total).should == nil
        response.should render_template("opportunities/destroy")
      end

      describe "when called from Opportunities index page" do
        before do
          request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        end

        it "should get sidebar data if called from opportunities index" do
          xhr :delete, :destroy, :id => @opportunity.id
          assigns(:opportunity_stage_total).should be_an_instance_of(HashWithIndifferentAccess)
        end

        it "should try previous page and render index action if current page has no opportunities" do
          session[:opportunities_current_page] = 42

          xhr :delete, :destroy, :id => @opportunity.id
          session[:opportunities_current_page].should == 41
          response.should render_template("opportunities/index")
        end

        it "should render index action when deleting last opportunity" do
          session[:opportunities_current_page] = 1

          xhr :delete, :destroy, :id => @opportunity.id
          session[:opportunities_current_page].should == 1
          response.should render_template("opportunities/index")
        end
      end

      describe "when called from related asset page" do
        it "should reset current page to 1" do
          request.env["HTTP_REFERER"] = "http://localhost/accounts/123"

          xhr :delete, :destroy, :id => @opportunity.id
          session[:opportunities_current_page].should == 1
          response.should render_template("opportunities/destroy")
        end

        it "should reload campaiign to be able to refresh its summary" do
          @account = Factory(:account)
          @opportunity = Factory(:opportunity, :user => @current_user, :account => @account)
          request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

          xhr :delete, :destroy, :id => @opportunity.id
          assigns[:account].should == @account
          response.should render_template("opportunities/destroy")
        end

        it "should reload campaiign to be able to refresh its summary" do
          @campaign = Factory(:campaign)
          @opportunity = Factory(:opportunity, :user => @current_user, :campaign => @campaign)
          request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

          xhr :delete, :destroy, :id => @opportunity.id
          assigns[:campaign].should == @campaign
          response.should render_template("opportunities/destroy")
        end
      end

      describe "opportunity got deleted or otherwise unavailable" do
        it "should reload current page is the opportunity got deleted" do
          @opportunity = Factory(:opportunity, :user => @current_user)
          @opportunity.destroy

          xhr :delete, :destroy, :id => @opportunity.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the opportunity is protected" do
          @private = Factory(:opportunity, :user => Factory(:user), :access => "Private")

          xhr :delete, :destroy, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "HTML request" do
      it "should redirect to Opportunities index when an opportunity gets deleted from its landing page" do
        delete :destroy, :id => @opportunity.id
        flash[:notice].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should redirect to opportunity index with the flash message is the opportunity got deleted" do
        @opportunity = Factory(:opportunity, :user => @current_user)
        @opportunity.destroy

        delete :destroy, :id => @opportunity.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should redirect to opportunity index with the flash message if the opportunity is protected" do
        @private = Factory(:opportunity, :user => Factory(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end
    end

  end

  # GET /opportunities/search/query                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET search" do
    before do
      @first  = Factory(:opportunity, :user => @current_user, :name => "The first one")
      @second = Factory(:opportunity, :user => @current_user, :name => "The second one")
      @opportunities = [ @first, @second ]
    end

    it "should perform lookup using query string and redirect to index" do
      xhr :get, :search, :query => "second"

      assigns[:opportunities].should == [ @second ]
      assigns[:current_query].should == "second"
      session[:opportunities_current_query].should == "second"
      response.should render_template("index")
    end

    describe "with mime type of XML" do
      it "should perform lookup using query string and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :search, :query => "second?!"

        response.body.should == [ @second.reload ].to_xml
      end
    end
  end

  # PUT /opportunities/1/attach
  # PUT /opportunities/1/attach.xml                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = Factory(:opportunity)
        @attachment = Factory(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "contacts" do
      before do
        @model = Factory(:opportunity)
        @attachment = Factory(:contact)
      end
      it_should_behave_like("attach")
    end
  end

  # POST /opportunities/1/discard
  # POST /opportunities/1/discard.xml                                      AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST discard" do
    describe "tasks" do
      before do
        @model = Factory(:opportunity)
        @attachment = Factory(:task, :asset => @model)
      end
      it_should_behave_like("discard")
    end

    describe "contacts" do
      before do
        @attachment = Factory(:contact)
        @model = Factory(:opportunity)
        @model.contacts << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before do
      @auto_complete_matches = [ Factory(:opportunity, :name => "Hello World", :user => @current_user) ]
    end

    it_should_behave_like("auto complete")
  end

  # GET /opportunities/options                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET options" do
    it "should set current user preferences when showing options" do
      @per_page = Factory(:preference, :user => @current_user, :name => "opportunities_per_page", :value => Base64.encode64(Marshal.dump(42)))
      @outline  = Factory(:preference, :user => @current_user, :name => "opportunities_outline",  :value => Base64.encode64(Marshal.dump("option_long")))
      @sort_by  = Factory(:preference, :user => @current_user, :name => "opportunities_sort_by",  :value => Base64.encode64(Marshal.dump("opportunities.name ASC")))

      xhr :get, :options
      assigns[:per_page].should == 42
      assigns[:outline].should  == "option_long"
      assigns[:sort_by].should  == "opportunities.name ASC"
    end

    it "should not assign instance variables when hiding options" do
      xhr :get, :options, :cancel => "true"
      assigns[:per_page].should == nil
      assigns[:outline].should  == nil
      assigns[:sort_by].should  == nil
    end
  end

  # POST /opportunities/redraw                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected opportunity preference" do
      xhr :post, :redraw, :per_page => 42, :outline => "brief", :sort_by => "name"
      @current_user.preference[:opportunities_per_page].should == 42
      @current_user.preference[:opportunities_outline].should  == "brief"
      @current_user.preference[:opportunities_sort_by].should  == "opportunities.name ASC"
    end

    it "should reset current page to 1" do
      xhr :post, :redraw, :per_page => 42, :outline => "brief", :sort_by => "name"
      session[:opportunities_current_page].should == 1
    end

    it "should select @opportunities and render [index] template" do
      @opportunities = [
        Factory(:opportunity, :name => "A", :user => @current_user),
        Factory(:opportunity, :name => "B", :user => @current_user)
      ]

      xhr :post, :redraw, :per_page => 1, :sort_by => "name"
      assigns(:opportunities).should == [ @opportunities.first ]
      response.should render_template("opportunities/index")
    end
  end

  # POST /opportunities/filter                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET filter" do

    it "should expose filtered opportunities as @opportunity and render [filter] template" do
      session[:filter_by_opportunity_stage] = "negotiation,analysis"
      @opportunities = [ Factory(:opportunity, :stage => "prospecting", :user => @current_user) ]
      @stage = Setting.unroll(:opportunity_stage)

      xhr :get, :filter, :stage => "prospecting"
      assigns(:opportunities).should == @opportunities
      assigns[:stage].should == @stage
      response.should be_a_success
      response.should render_template("opportunities/index")
    end

    it "should reset current page to 1" do
      @opportunities = []
      xhr :get, :filter, :status => "new"

      session[:opportunities_current_page].should == 1
    end

  end

end

