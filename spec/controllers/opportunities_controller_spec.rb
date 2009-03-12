require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do

  def get_data_for_sidebar
    @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
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
      @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }
      @comment = Comment.new

      get :show, :id => 42
      assigns[:opportunity].should == @opportunity
      assigns[:stage].should == @stage
      assigns[:comment].attributes.should == @comment.attributes
    end
    
    describe "with mime type of xml" do

      it "should render the requested opportunity as xml" do
        @opportunity = Factory(:opportunity, :id => 42)
        @stage = Setting.opportunity_stage.inject({}) { |hash, item| hash[item.last] = item.first; hash }

        request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => 42
        response.body.should == @opportunity.to_xml
      end
      
    end
    
  end
  
  # describe "responding to GET new" do
  # 
  #   it "should expose a new opportunity as @opportunity" do
  #     Opportunity.should_receive(:new).and_return(mock_opportunity)
  #     get :new
  #     assigns[:opportunity].should equal(mock_opportunity)
  #   end
  # 
  # end
  # 
  # describe "responding to GET edit" do
  # 
  #   it "should expose the requested opportunity as @opportunity" do
  #     Opportunity.should_receive(:find).with(@uuid).and_return(mock_opportunity)
  #     get :edit, :id => @uuid
  #     assigns[:opportunity].should equal(mock_opportunity)
  #   end
  # 
  # end
  # 
  # describe "responding to POST create" do
  # 
  #   describe "with valid params" do
  #     
  #     it "should expose a newly created opportunity as @opportunity" do
  #       @opportunity = mock_opportunity(:save => true)
  #       @account     = mock_model(Account)
  #       @users       = [ mock_model(User) ]
  #       @accounts    = [ mock_model(Account) ]
  # 
  #       Opportunity.should_receive(:new).with({'opportunity' => 'params'}).and_return(@opportunity)
  #       Account.should_receive(:new).with({'account' => 'params'}).and_return(@account)
  #       User.should_receive(:all_except).with(@current_user).and_return(@users)
  #       Account.should_receive(:find).with(:all, :order => "name").and_return(@accounts)
  #       @opportunity.should_receive(:save_with_account_and_permissions).with({"account"=>{"account"=>"params"}, "opportunity"=>{"opportunity"=>"params"}, "action"=>"create", "controller"=>"opportunities", "users"=>["1", "2", "3"]}).and_return(true)
  #       post :create, :opportunity => {:opportunity => "params"}, :account => {:account => "params"}, :users => %w(1 2 3)
  #       assigns(:opportunity).should equal(@opportunity)
  #       assigns(:account).should equal(@account)
  #       assigns(:users).should equal(@users)
  #       assigns(:accounts).should equal(@accounts)
  #     end
  # 
  #     it "should redirect to the created opportunity" do
  #       Opportunity.stub!(:new).and_return(@opportunity = mock_opportunity(:save => true))
  #       @opportunity.should_receive(:save_with_account_and_permissions).with({"opportunity"=>{}, "action"=>"create", "controller"=>"opportunities"}).and_return(true)
  #       post :create, :opportunity => {}
  #       response.should redirect_to(opportunity_url(mock_opportunity))
  #     end
  #     
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should expose a newly created but unsaved opportunity as @opportunity" do
  #       @opportunity = mock_opportunity(:save => false)
  #       @account     = mock_model(Account)
  #       @users       = [ mock_model(User) ]
  #       @accounts    = [ mock_model(Account) ]
  # 
  #       Opportunity.should_receive(:new).with({'opportunity' => 'params'}).and_return(@opportunity)
  #       Account.should_receive(:new).with({'account' => 'params'}).and_return(@account)
  #       User.should_receive(:all_except).with(@current_user).and_return(@users)
  #       Account.should_receive(:find).with(:all, :order => "name").and_return(@accounts)
  #       @opportunity.should_receive(:save_with_account_and_permissions).with({"opportunity"=>{"opportunity"=>"params"}, "account"=>{"account"=>"params"}, "action"=>"create", "controller"=>"opportunities", "users"=>["1", "2", "3"]}).and_return(true)
  #       post :create, :opportunity => {:opportunity => "params"}, :account => {:account => "params"}, :users => %w(1 2 3)
  #       assigns(:opportunity).should equal(@opportunity)
  #       assigns(:account).should equal(@account)
  #       assigns(:users).should equal(@users)
  #       assigns(:accounts).should equal(@accounts)
  #     end
  # 
  #     it "should re-render the 'new' template" do
  #       Opportunity.stub!(:new).and_return(@opp = mock_opportunity(:save => false))
  #       @opp.should_receive(:save_with_account_and_permissions).with({"opportunity"=>{}, "action"=>"create", "controller"=>"opportunities"}).and_return(false)
  #       post :create, :opportunity => {}
  #       response.should render_template('new')
  #     end
  #     
  #   end
  #   
  # end
  # 
  # describe "responding to PUT udpate" do
  # 
  #   describe "with valid params" do
  # 
  #     it "should update the requested opportunity" do
  #       Opportunity.should_receive(:find).with(@uuid).and_return(mock_opportunity)
  #       mock_opportunity.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => @uuid, :opportunity => {:these => 'params'}
  #     end
  # 
  #     it "should expose the requested opportunity as @opportunity" do
  #       Opportunity.stub!(:find).and_return(mock_opportunity(:update_attributes => true))
  #       put :update, :id => @uuid
  #       assigns(:opportunity).should equal(mock_opportunity)
  #     end
  # 
  #     it "should redirect to the opportunity" do
  #       Opportunity.stub!(:find).and_return(mock_opportunity(:update_attributes => true))
  #       put :update, :id => @uuid
  #       response.should redirect_to(opportunity_url(mock_opportunity))
  #     end
  # 
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should update the requested opportunity" do
  #       Opportunity.should_receive(:find).with(@uuid).and_return(mock_opportunity)
  #       mock_opportunity.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => @uuid, :opportunity => {:these => 'params'}
  #     end
  # 
  #     it "should expose the opportunity as @opportunity" do
  #       Opportunity.stub!(:find).and_return(mock_opportunity(:update_attributes => false))
  #       put :update, :id => @uuid
  #       assigns(:opportunity).should equal(mock_opportunity)
  #     end
  # 
  #     it "should re-render the 'edit' template" do
  #       Opportunity.stub!(:find).and_return(mock_opportunity(:update_attributes => false))
  #       put :update, :id => @uuid
  #       response.should render_template('edit')
  #     end
  # 
  #   end
  # 
  # end
  # 
  # describe "responding to DELETE destroy" do
  # 
  #   it "should destroy the requested opportunity" do
  #     Opportunity.should_receive(:find).with(@uuid).and_return(mock_opportunity)
  #     mock_opportunity.should_receive(:destroy)
  #     delete :destroy, :id => @uuid
  #   end
  # 
  #   it "should redirect to the opportunities list" do
  #     Opportunity.stub!(:find).and_return(mock_opportunity(:destroy => true))
  #     delete :destroy, :id => @uuid
  #     response.should redirect_to(opportunities_url)
  #   end
  # 
  # end

end
