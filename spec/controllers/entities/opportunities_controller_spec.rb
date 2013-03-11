require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OpportunitiesController do

  def get_data_for_sidebar
    @stage = Setting.unroll(:opportunity_stage)
  end

  let(:user) do
    FactoryGirl.create(:user)
  end

  before(:each) do
    @current_user = user
    sign_in(:user, @current_user)
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
      @opportunities = [ FactoryGirl.create(:opportunity, :user => current_user) ]

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
      controller.session[:opportunities_filter] = "prospecting,negotiation"
      @opportunities = [
        FactoryGirl.create(:opportunity, :user => current_user, :stage => "negotiation"),
        FactoryGirl.create(:opportunity, :user => current_user, :stage => "prospecting")
      ]
      # This one should be filtered out.
      FactoryGirl.create(:opportunity, :user => current_user, :stage => "analysis")

      get :index
      # Note: can't compare opportunities directly because of BigDecimal objects.
      assigns[:opportunities].size.should == 2
      assigns[:opportunities].map(&:stage).sort.should == %w(negotiation prospecting)
    end

    it "should perform lookup using query string" do
      @first  = FactoryGirl.create(:opportunity, :user => current_user, :name => "The first one")
      @second = FactoryGirl.create(:opportunity, :user => current_user, :name => "The second one")

      get :index, :query => "second"
      assigns[:opportunities].should == [ @second ]
      assigns[:current_query].should == "second"
      session[:opportunities_current_query].should == "second"
    end

    describe "AJAX pagination" do
      it "should pick up page number from params" do
        @opportunities = [ FactoryGirl.create(:opportunity, :user => current_user) ]
        xhr :get, :index, :page => 42

        assigns[:current_page].to_i.should == 42
        assigns[:opportunities].should == [] # page #42 should be empty if there's only one opportunity ;-)
        session[:opportunities_current_page].to_i.should == 42
        response.should render_template("opportunities/index")
      end

      it "should pick up saved page number from session" do
        session[:opportunities_current_page] = 42
        @opportunities = [ FactoryGirl.create(:opportunity, :user => current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 42
        assigns[:opportunities].should == []
        response.should render_template("opportunities/index")
      end

      it "should reset current_page when query is altered" do
        session[:opportunities_current_page] = 42
        session[:opportunities_current_query] = "bill"
        @opportunities = [ FactoryGirl.create(:opportunity, :user => current_user) ]
        xhr :get, :index

        assigns[:current_page].should == 1
        assigns[:opportunities].should == @opportunities
        response.should render_template("opportunities/index")
      end
    end

    describe "with mime type of JSON" do
      it "should render all opportunities as JSON" do
        @controller.should_receive(:get_opportunities).and_return(opportunities = mock("Array of Opportunities"))
        opportunities.should_receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        response.body.should == "generated JSON"
      end
    end

    describe "with mime type of JSON" do
      it "should render all opportunities as JSON" do
        @controller.should_receive(:get_opportunities).and_return(opportunities = mock("Array of Opportunities"))
        opportunities.should_receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :index
        response.body.should == "generated JSON"
      end
    end

    describe "with mime type of XML" do
      it "should render all opportunities as xml" do
        @controller.should_receive(:get_opportunities).and_return(opportunities = mock("Array of Opportunities"))
        opportunities.should_receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.body.should == "generated XML"
      end
    end
  end

  # GET /opportunities/1
  # GET /opportunities/1.xml                                               HTML
  #----------------------------------------------------------------------------
  describe "responding to GET show" do

    describe "with mime type of HTML" do
      before do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)
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
        get :show, :id => @opportunity.id
        @opportunity.versions.last.event.should == 'view'
      end
    end

    describe "with mime type of JSON" do
      it "should render the requested opportunity as JSON" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)
        Opportunity.should_receive(:find).and_return(@opportunity)
        @opportunity.should_receive(:to_json).and_return("generated JSON")

        request.env["HTTP_ACCEPT"] = "application/json"
        get :show, :id => 42
        response.body.should == "generated JSON"
      end
    end

    describe "with mime type of XML" do
      it "should render the requested opportunity as xml" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)
        Opportunity.should_receive(:find).and_return(@opportunity)
        @opportunity.should_receive(:to_xml).and_return("generated XML")

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == "generated XML"
      end
    end

    describe "opportunity got deleted or otherwise unavailable" do
      it "should redirect to opportunity index if the opportunity got deleted" do
        @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
        @opportunity.destroy

        get :show, :id => @opportunity.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should redirect to opportunity index if the opportunity is protected" do
        @private = FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :access => "Private")

        get :show, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should return 404 (Not Found) JSON error" do
        @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
        @opportunity.destroy
        request.env["HTTP_ACCEPT"] = "application/json"

        get :show, :id => @opportunity.id
        response.code.should == "404" # :not_found
      end

      it "should return 404 (Not Found) XML error" do
        @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
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
      @opportunity = Opportunity.new(:user => current_user, :access => Setting.default_access, :stage => "prospecting")
      @account = Account.new(:user => current_user, :access => Setting.default_access)
      @accounts = [ FactoryGirl.create(:account, :user => current_user) ]

      xhr :get, :new
      assigns[:opportunity].attributes.should == @opportunity.attributes
      assigns[:account].attributes.should == @account.attributes
      assigns[:accounts].should == @accounts
      response.should render_template("opportunities/new")
    end

    it "should created an instance of related object when necessary" do
      @contact = FactoryGirl.create(:contact, :id => 42)

      xhr :get, :new, :related => "contact_42"
      assigns[:contact].should == @contact
    end

    describe "(when creating related opportunity)" do
      it "should redirect to parent asset's index page with the message if parent asset got deleted" do
        @account = FactoryGirl.create(:account)
        @account.destroy

        xhr :get, :new, :related => "account_#{@account.id}"
        flash[:warning].should_not == nil
        response.body.should == 'window.location.href = "/accounts";'
      end

      it "should redirect to parent asset's index page with the message if parent asset got protected" do
        @account = FactoryGirl.create(:account, :access => "Private")

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
      @account = FactoryGirl.create(:account, :user => current_user)
      @opportunity = FactoryGirl.create(:opportunity, :id => 42, :user => current_user, :campaign => nil,
                             :account => @account)
      @stage = Setting.unroll(:opportunity_stage)
      @accounts = [ @account ]

      xhr :get, :edit, :id => 42
      @opportunity.reload
      assigns[:opportunity].should == @opportunity
      assigns[:account].attributes.should == @opportunity.account.attributes
      assigns[:accounts].should == @accounts
      assigns[:stage].should == @stage
      assigns[:previous].should == nil
      response.should render_template("opportunities/edit")
    end

    it "should expose previous opportunity as @previous when necessary" do
      @opportunity = FactoryGirl.create(:opportunity, :id => 42)
      @previous = FactoryGirl.create(:opportunity, :id => 41)

      xhr :get, :edit, :id => 42, :previous => 41
      assigns[:previous].should == @previous
    end

    describe "opportunity got deleted or is otherwise unavailable" do
      it "should reload current page with the flash message if the opportunity got deleted" do
        @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
        @opportunity.destroy

        xhr :get, :edit, :id => @opportunity.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end

      it "should reload current page with the flash message if the opportunity is protected" do
        @private = FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :access => "Private")

        xhr :get, :edit, :id => @private.id
        flash[:warning].should_not == nil
        response.body.should == "window.location.reload();"
      end
    end

    describe "(previous opportunity got deleted or is otherwise unavailable)" do
      before do
        @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
        @previous = FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user))
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
        @opportunity = FactoryGirl.build(:opportunity, :user => current_user)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.unroll(:opportunity_stage)
      end

      it "should expose a newly created opportunity as @opportunity and render [create] template" do
        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :name => "Hello again" }
        assigns(:opportunity).should == @opportunity
        assigns(:stage).should == @stage
        assigns(:opportunity_stage_total).should be_nil
        response.should render_template("opportunities/create")
      end

      it "should get sidebar data if called from opportunities index" do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :name => "Hello again" }
        assigns(:opportunity_stage_total).should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should find related account if called from account landing page" do
        @account = FactoryGirl.create(:account, :user => current_user)
        request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :id => @account.id }
        assigns(:account).should == @account
      end

      it "should find related campaign if called from campaign landing page" do
        @campaign = FactoryGirl.create(:campaign, :user => current_user)
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

        xhr :post, :create, :opportunity => { :name => "Hello" }, :campaign => @campaign.id, :account => { :name => "Hello again" }
        assigns(:campaign).should == @campaign
      end

      it "should reload opportunities to update pagination if called from opportunities index" do
        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :account => { :name => "Hello again" }
        assigns[:opportunities].should == [ @opportunity ]
      end

      it "should associate opportunity with the campaign when called from campaign landing page" do
        @campaign = FactoryGirl.create(:campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :campaign => @campaign.id, :account => { :name => "Test Account" }
        assigns(:opportunity).should == @opportunity
        assigns(:campaign).should == @campaign
        @opportunity.campaign.should == @campaign
      end

      it "should associate opportunity with the contact when called from contact landing page" do
        @contact = FactoryGirl.create(:contact, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/contacts/42"
        xhr :post, :create, :opportunity => { :name => "Hello" }, :contact => 42, :account => { :name => "Hello again" }
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
        @account = FactoryGirl.create(:account, :id => 42)

        xhr :post, :create, :opportunity => { :name => "Hello world" }, :account => { :id => 42 }
        assigns(:opportunity).should == @opportunity
        @opportunity.account.should == @account
        @account.opportunities.should include(@opportunity)
      end

      it "should update related campaign revenue if won" do
        @campaign = FactoryGirl.create(:campaign, :revenue => 0)
        @opportunity = FactoryGirl.build(:opportunity, :user => current_user, :stage => "won", :amount => 1100, :discount => 100)
        Opportunity.stub!(:new).and_return(@opportunity)

        xhr :post, :create, :opportunity => { :name => "Hello world" }, :campaign => @campaign.id, :account => { :name => "Test Account" }
        assigns(:opportunity).should == @opportunity
        @opportunity.campaign.should == @campaign.reload
        @campaign.revenue.to_i.should == 1000 # 1000 - 100 discount.
      end

      it "should add a new comment to the newly created opportunity when specified" do
        @opportunity = FactoryGirl.build(:opportunity, :user => current_user)
        Opportunity.stub!(:new).and_return(@opportunity)

        xhr :post, :create, :opportunity => { :name => "Opportunity Knocks" }, :account => { :name => "My Account" }, :comment_body => "Awesome comment is awesome"
        @opportunity.reload.comments.map(&:comment).should include("Awesome comment is awesome")
      end
    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved opportunity as @opportunity with blank @account and render [create] template" do
        @account = Account.new(:user => current_user)
        @opportunity = FactoryGirl.build(:opportunity, :name => nil, :campaign => nil, :user => current_user,
                                     :account => @account)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.unroll(:opportunity_stage)
        @accounts = [ FactoryGirl.create(:account, :user => current_user) ]

        # Expect to redraw [create] form with blank account.
        xhr :post, :create, :opportunity => {}, :account => { :user_id => current_user.id }
        assigns(:opportunity).should == @opportunity
        assigns(:account).attributes.should == @account.attributes
        assigns(:accounts).should == @accounts
        response.should render_template("opportunities/create")
      end

      it "should expose a newly created but unsaved opportunity as @opportunity with existing @account and render [create] template" do
        @account = FactoryGirl.create(:account, :id => 42, :user => current_user)
        @opportunity = FactoryGirl.build(:opportunity, :name => nil, :campaign => nil, :user => current_user,
                                     :account => @account)
        Opportunity.stub!(:new).and_return(@opportunity)
        @stage = Setting.unroll(:opportunity_stage)

        # Expect to redraw [create] form with selected account.
        xhr :post, :create, :opportunity => {}, :account => { :id => 42, :user_id => current_user.id }
        assigns(:opportunity).should == @opportunity
        assigns(:account).should == @account
        assigns(:accounts).should == [ @account ]
        response.should render_template("opportunities/create")
      end

      it "should preserve the campaign when called from campaign landing page" do
        @campaign = FactoryGirl.create(:campaign, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/42"
        xhr :post, :create, :opportunity => { :name => nil }, :campaign => 42, :account => { :name => "Test Account" }
        assigns(:campaign).should == @campaign
        response.should render_template("opportunities/create")
      end

      it "should preserve the contact when called from contact landing page" do
        @contact = FactoryGirl.create(:contact, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/contacts/42"
        xhr :post, :create, :opportunity => { :name => nil }, :contact => 42, :account => { :name => "Test Account" }
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
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)
        @stage = Setting.unroll(:opportunity_stage)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }, :account => { :name => "Test Account" }
        @opportunity.reload.name.should == "Hello world"
        assigns(:opportunity).should == @opportunity
        assigns(:stage).should == @stage
        assigns(:opportunity_stage_total).should == nil
        response.should render_template("opportunities/update")
      end

      it "should get sidebar data if called from opportunities index" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)

        request.env["HTTP_REFERER"] = "http://localhost/opportunities"
        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }, :account => { :name => "Test Account" }
        assigns(:opportunity_stage_total).should be_an_instance_of(HashWithIndifferentAccess)
      end

      it "should find related account if called from account landing page" do
        @account = FactoryGirl.create(:account, :user => current_user)
        @opportunity = FactoryGirl.create(:opportunity, :id => 42, :account => @account)
        request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }
        assigns(:account).should == @account
      end

      it "should remove related account if blank :account param is given" do
        @account = FactoryGirl.create(:account, :user => current_user)
        @opportunity = FactoryGirl.create(:opportunity, :id => 42, :account => @account)
        request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world" }, :account => { :id => "" }
        assigns(:account).should == nil
      end

      it "should find related campaign if called from campaign landing page" do
        @campaign = FactoryGirl.create(:campaign, :user => current_user)
        @opportunity = FactoryGirl.create(:opportunity, :id => 42, :user => current_user)
        @campaign.opportunities << @opportunity
        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello world", :campaign_id => @campaign.id }, :account => {}
        assigns(:campaign).should == @campaign
      end

      it "should be able to create an account and associate it with updated opportunity" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello" }, :account => { :name => "new account" }
        assigns[:opportunity].should == @opportunity
        @opportunity.reload
        @opportunity.account.should_not be_nil
        @opportunity.account.name.should == "new account"
      end

      it "should be able to create an account and associate it with updated opportunity" do
        @old_account = FactoryGirl.create(:account, :id => 111)
        @new_account = FactoryGirl.create(:account, :id => 999)
        @opportunity = FactoryGirl.create(:opportunity, :id => 42, :account => @old_account)

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello" }, :account => { :id => 999 }
        assigns[:opportunity].should == @opportunity
        assigns[:opportunity].account.should == @new_account
      end

      it "should update opportunity permissions when sharing with specific users" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42, :access => "Public")

        xhr :put, :update, :id => 42, :opportunity => { :name => "Hello", :access => "Shared", :user_ids => [7, 8] }, :account => { :name => "Test Account" }
        assigns[:opportunity].access.should == "Shared"
        assigns[:opportunity].user_ids.sort.should == [ 7, 8 ]
      end

      it "should reload opportunity campaign if called from campaign landing page" do
        @campaign = FactoryGirl.create(:campaign)
        @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign)

        request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"
        xhr :put, :update, :id => @opportunity.id, :opportunity => { :name => "Hello" }, :account => { :name => "Test Account" }
        assigns[:campaign].should == @campaign
      end

      describe "updating campaign revenue (same campaign)" do
        it "should add to actual revenue when opportunity is closed/won" do
          @campaign = FactoryGirl.create(:campaign, :revenue => 1000)
          @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign, :stage => 'prospecting', :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "won" }, :account => { :name => "Test Account" }
          @campaign.reload.revenue.to_i.should == 2000 # 1000 -> 2000
        end

        it "should substract from actual revenue when opportunity is no longer closed/won" do
          @campaign = FactoryGirl.create(:campaign, :revenue => 1000)
          @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign, :stage => "won", :amount => 1100, :discount => 100)
          # @campaign.revenue is now $2000 since we created winning opportunity.

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => 'prospecting' }, :account => { :name => "Test Account" }
          @campaign.reload.revenue.to_i.should == 1000 # Should be adjusted back to $1000.
        end

        it "should not update actual revenue when opportunity is not closed/won" do
          @campaign = FactoryGirl.create(:campaign, :revenue => 1000)
          @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign, :stage => 'prospecting', :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "lost" }, :account => { :name => "Test Account" }
          @campaign.reload.revenue.to_i.should == 1000 # Stays the same.
        end
      end

      describe "updating campaign revenue (diferent campaigns)" do
        it "should update newly assigned campaign when opportunity is closed/won" do
          @campaigns = { :old => FactoryGirl.create(:campaign, :revenue => 1000), :new => FactoryGirl.create(:campaign, :revenue => 1000) }
          @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaigns[:old], :stage => 'prospecting', :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "won", :campaign_id => @campaigns[:new].id }, :account => { :name => "Test Account" }

          @campaigns[:old].reload.revenue.to_i.should == 1000 # Stays the same.
          @campaigns[:new].reload.revenue.to_i.should == 2000 # 1000 -> 2000
        end

        it "should update old campaign when opportunity is no longer closed/won" do
          @campaigns = { :old => FactoryGirl.create(:campaign, :revenue => 1000), :new => FactoryGirl.create(:campaign, :revenue => 1000) }
          @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaigns[:old], :stage => "won", :amount => 1100, :discount => 100)
          # @campaign.revenue is now $2000 since we created winning opportunity.

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => 'prospecting', :campaign_id => @campaigns[:new].id }, :account => { :name => "Test Account" }
          @campaigns[:old].reload.revenue.to_i.should == 1000 # Should be adjusted back to $1000.
          @campaigns[:new].reload.revenue.to_i.should == 1000 # Stays the same.
        end

        it "should not update campaigns when opportunity is not closed/won" do
          @campaigns = { :old => FactoryGirl.create(:campaign, :revenue => 1000), :new => FactoryGirl.create(:campaign, :revenue => 1000) }
          @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaigns[:old], :stage => 'prospecting', :amount => 1100, :discount => 100)

          xhr :put, :update, :id => @opportunity, :opportunity => { :stage => "lost", :campaign_id => @campaigns[:new].id }, :account => { :name => "Test Account" }
          @campaigns[:old].reload.revenue.to_i.should == 1000 # Stays the same.
          @campaigns[:new].reload.revenue.to_i.should == 1000 # Stays the same.
        end
      end

      describe "opportunity got deleted or otherwise unavailable" do
        it "should reload current page with the flash message if the opportunity got deleted" do
          @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
          @opportunity.destroy

          xhr :put, :update, :id => @opportunity.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the opportunity is protected" do
          @private = FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :access => "Private")

          xhr :put, :update, :id => @private.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end
      end
    end

    describe "with invalid params" do

      it "should not update the requested opportunity but still expose it as @opportunity, and render [update] template" do
        @opportunity = FactoryGirl.create(:opportunity, :id => 42, :name => "Hello people")

        xhr :put, :update, :id => 42, :opportunity => { :name => nil }, :account => { :name => "Test Account" }
        @opportunity.reload.name.should == "Hello people"
        assigns(:opportunity).should == @opportunity
        assigns(:opportunity_stage_total).should == nil
        response.should render_template("opportunities/update")
      end

      it "should expose existing account as @account if selected" do
        @account = FactoryGirl.create(:account, :id => 99)
        @opportunity = FactoryGirl.create(:opportunity, :id => 42)
        FactoryGirl.create(:account_opportunity, :account => @account, :opportunity => @opportunity)

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
      @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
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
          @account = FactoryGirl.create(:account)
          @opportunity = FactoryGirl.create(:opportunity, :user => current_user, :account => @account)
          request.env["HTTP_REFERER"] = "http://localhost/accounts/#{@account.id}"

          xhr :delete, :destroy, :id => @opportunity.id
          assigns[:account].should == @account
          response.should render_template("opportunities/destroy")
        end

        it "should reload campaiign to be able to refresh its summary" do
          @campaign = FactoryGirl.create(:campaign)
          @opportunity = FactoryGirl.create(:opportunity, :user => current_user, :campaign => @campaign)
          request.env["HTTP_REFERER"] = "http://localhost/campaigns/#{@campaign.id}"

          xhr :delete, :destroy, :id => @opportunity.id
          assigns[:campaign].should == @campaign
          response.should render_template("opportunities/destroy")
        end
      end

      describe "opportunity got deleted or otherwise unavailable" do
        it "should reload current page is the opportunity got deleted" do
          @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
          @opportunity.destroy

          xhr :delete, :destroy, :id => @opportunity.id
          flash[:warning].should_not == nil
          response.body.should == "window.location.reload();"
        end

        it "should reload current page with the flash message if the opportunity is protected" do
          @private = FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :access => "Private")

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
        @opportunity = FactoryGirl.create(:opportunity, :user => current_user)
        @opportunity.destroy

        delete :destroy, :id => @opportunity.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end

      it "should redirect to opportunity index with the flash message if the opportunity is protected" do
        @private = FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :access => "Private")

        delete :destroy, :id => @private.id
        flash[:warning].should_not == nil
        response.should redirect_to(opportunities_path)
      end
    end
  end

  # PUT /opportunities/1/attach
  # PUT /opportunities/1/attach.xml                                        AJAX
  #----------------------------------------------------------------------------
  describe "responding to PUT attach" do
    describe "tasks" do
      before do
        @model = FactoryGirl.create(:opportunity)
        @attachment = FactoryGirl.create(:task, :asset => nil)
      end
      it_should_behave_like("attach")
    end

    describe "contacts" do
      before do
        @model = FactoryGirl.create(:opportunity)
        @attachment = FactoryGirl.create(:contact)
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
        @model = FactoryGirl.create(:opportunity)
        @attachment = FactoryGirl.create(:task, :asset => @model)
      end
      it_should_behave_like("discard")
    end

    describe "contacts" do
      before do
        @attachment = FactoryGirl.create(:contact)
        @model = FactoryGirl.create(:opportunity)
        @model.contacts << @attachment
      end
      it_should_behave_like("discard")
    end
  end

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST auto_complete" do
    before do
      @auto_complete_matches = [ FactoryGirl.create(:opportunity, :name => "Hello World", :user => current_user) ]
    end

    it_should_behave_like("auto complete")
  end

  # POST /opportunities/redraw                                             AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST redraw" do
    it "should save user selected opportunity preference" do
      xhr :post, :redraw, :per_page => 42, :view => "brief", :sort_by => "name"
      current_user.preference[:opportunities_per_page].should == "42"
      current_user.preference[:opportunities_index_view].should  == "brief"
      current_user.preference[:opportunities_sort_by].should  == "opportunities.name ASC"
    end

    it "should reset current page to 1" do
      xhr :post, :redraw, :per_page => 42, :view => "brief", :sort_by => "name"
      session[:opportunities_current_page].should == 1
    end

    it "should select @opportunities and render [index] template" do
      @opportunities = [
        FactoryGirl.create(:opportunity, :name => "A", :user => current_user),
        FactoryGirl.create(:opportunity, :name => "B", :user => current_user)
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
      session[:opportunities_filter] = "negotiation,analysis"
      @opportunities = [ FactoryGirl.create(:opportunity, :stage => "prospecting", :user => current_user) ]
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
