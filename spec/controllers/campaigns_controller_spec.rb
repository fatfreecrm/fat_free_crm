require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CampaignsController do

  def get_data_for_sidebar
    Setting.stub!(:campaign_status).and_return({ :key => "value" })
    Campaign.should_receive(:my).twice.and_return(campaigns = [ mock_model(Campaign) ])
    campaigns.should_receive(:count).twice.and_return(42)
  end

  before(:each) do
    require_user
    set_current_tab(:campaigns)
    @uuid = "12345678-0123-5678-0123-567890123456"
  end

  def mock_campaign(stubs = { :user => mock_model(User) } )
    @mock_campaign ||= mock_model(Campaign, stubs)
  end
  
  describe "responding to GET index" do

    before(:each) do
      get_data_for_sidebar
    end

    it "should expose all campaigns as @campaigns" do
      Campaign.stub!(:my).with(@current_user).and_return([mock_campaign])
      get :index
      assigns[:campaigns].should == [mock_campaign]
    end

    describe "with mime type of xml" do
  
      it "should render all campaigns as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Campaign.stub!(:my).with(@current_user).and_return(campaigns = mock("Array of Campaigns"))
        campaigns.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested campaign as @campaign" do
      Campaign.should_receive(:find).with(@uuid).and_return(mock_campaign)
      get :show, :id => @uuid
      assigns[:campaign].should equal(mock_campaign)
    end
    
    describe "with mime type of xml" do

      it "should render the requested campaign as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Campaign.should_receive(:find).with(@uuid).and_return(mock_campaign)
        mock_campaign.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => @uuid
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new campaign as @campaign" do
      Campaign.should_receive(:new).and_return(mock_campaign)
      get :new
      assigns[:campaign].should equal(mock_campaign)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested campaign as @campaign" do
      Campaign.should_receive(:find).with(@uuid).and_return(mock_campaign)
      get :edit, :id => @uuid
      assigns[:campaign].should equal(mock_campaign)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created campaign as @campaign" do
        @campaign = mock_campaign(:save => true)
        @users = [ mock_model(User) ]
        Campaign.should_receive(:new).with({'these' => 'params'}).and_return(@campaign)
        User.should_receive(:all_except).with(@current_user).and_return(@users)
        @campaign.should_receive(:save_with_permissions).with(%w(1 2 3)).and_return(true)
        post :create, :campaign => {:these => 'params'}, :users => %w(1 2 3)
        assigns(:campaign).should equal(mock_campaign)
        assigns(:users).should equal(@users)
      end

      it "should redirect to the created campaign" do
        Campaign.stub!(:new).and_return(@campaign = mock_campaign(:save => true))
        @campaign.should_receive(:save_with_permissions).with(nil).and_return(true)
        post :create, :campaign => {}
        response.should redirect_to(campaign_url(mock_campaign))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved campaign as @campaign" do
        @campaign = mock_campaign(:save => false)
        @users = [ mock_model(User) ]
        Campaign.stub!(:new).with({'these' => 'params'}).and_return(@campaign)
        User.should_receive(:all_except).with(@current_user).and_return(@users)
        @campaign.should_receive(:save_with_permissions).with(%w(1 2 3)).and_return(false)
        post :create, :campaign => {:these => 'params'}, :users => %w(1 2 3)
        assigns(:campaign).should equal(mock_campaign)
        assigns(:users).should equal(@users)
      end

      it "should re-render the 'new' template" do
        Campaign.stub!(:new).and_return(@campaign = mock_campaign(:save => false))
        @campaign.should_receive(:save_with_permissions).with(nil).and_return(false)
        post :create, :campaign => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested campaign" do
        Campaign.should_receive(:find).with(@uuid).and_return(mock_campaign)
        mock_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @uuid, :campaign => {:these => 'params'}
      end

      it "should expose the requested campaign as @campaign" do
        Campaign.stub!(:find).with(@uuid).and_return(mock_campaign(:update_attributes => true))
        put :update, :id => @uuid
        assigns(:campaign).should equal(mock_campaign)
      end

      it "should redirect to the campaign" do
        Campaign.stub!(:find).with(@uuid).and_return(mock_campaign(:update_attributes => true))
        put :update, :id => @uuid
        response.should redirect_to(campaign_url(mock_campaign))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested campaign" do
        Campaign.should_receive(:find).with(@uuid).and_return(mock_campaign)
        mock_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @uuid, :campaign => {:these => 'params'}
      end

      it "should expose the campaign as @campaign" do
        Campaign.stub!(:find).with(@uuid).and_return(mock_campaign(:update_attributes => false))
        put :update, :id => @uuid
        assigns(:campaign).should equal(mock_campaign)
      end

      it "should re-render the 'edit' template" do
        Campaign.stub!(:find).with(@uuid).and_return(mock_campaign(:update_attributes => false))
        put :update, :id => @uuid
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested campaign" do
      Campaign.should_receive(:find).with(@uuid).and_return(mock_campaign)
      mock_campaign.should_receive(:destroy)
      delete :destroy, :id => @uuid
    end
  
    it "should redirect to the campaigns list" do
      Campaign.stub!(:find).with(@uuid).and_return(mock_campaign(:destroy => true))
      delete :destroy, :id => @uuid
      response.should redirect_to(campaigns_url)
    end

  end

end
