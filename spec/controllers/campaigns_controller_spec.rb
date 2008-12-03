require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CampaignsController do

  def mock_campaign(stubs={})
    @mock_campaign ||= mock_model(Campaign, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all campaigns as @campaigns" do
      Campaign.should_receive(:find).with(:all).and_return([mock_campaign])
      get :index
      assigns[:campaigns].should == [mock_campaign]
    end

    describe "with mime type of xml" do
  
      it "should render all campaigns as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Campaign.should_receive(:find).with(:all).and_return(campaigns = mock("Array of Campaigns"))
        campaigns.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested campaign as @campaign" do
      Campaign.should_receive(:find).with("37").and_return(mock_campaign)
      get :show, :id => "37"
      assigns[:campaign].should equal(mock_campaign)
    end
    
    describe "with mime type of xml" do

      it "should render the requested campaign as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Campaign.should_receive(:find).with("37").and_return(mock_campaign)
        mock_campaign.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
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
      Campaign.should_receive(:find).with("37").and_return(mock_campaign)
      get :edit, :id => "37"
      assigns[:campaign].should equal(mock_campaign)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created campaign as @campaign" do
        Campaign.should_receive(:new).with({'these' => 'params'}).and_return(mock_campaign(:save => true))
        post :create, :campaign => {:these => 'params'}
        assigns(:campaign).should equal(mock_campaign)
      end

      it "should redirect to the created campaign" do
        Campaign.stub!(:new).and_return(mock_campaign(:save => true))
        post :create, :campaign => {}
        response.should redirect_to(campaign_url(mock_campaign))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved campaign as @campaign" do
        Campaign.stub!(:new).with({'these' => 'params'}).and_return(mock_campaign(:save => false))
        post :create, :campaign => {:these => 'params'}
        assigns(:campaign).should equal(mock_campaign)
      end

      it "should re-render the 'new' template" do
        Campaign.stub!(:new).and_return(mock_campaign(:save => false))
        post :create, :campaign => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested campaign" do
        Campaign.should_receive(:find).with("37").and_return(mock_campaign)
        mock_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :campaign => {:these => 'params'}
      end

      it "should expose the requested campaign as @campaign" do
        Campaign.stub!(:find).and_return(mock_campaign(:update_attributes => true))
        put :update, :id => "1"
        assigns(:campaign).should equal(mock_campaign)
      end

      it "should redirect to the campaign" do
        Campaign.stub!(:find).and_return(mock_campaign(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(campaign_url(mock_campaign))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested campaign" do
        Campaign.should_receive(:find).with("37").and_return(mock_campaign)
        mock_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :campaign => {:these => 'params'}
      end

      it "should expose the campaign as @campaign" do
        Campaign.stub!(:find).and_return(mock_campaign(:update_attributes => false))
        put :update, :id => "1"
        assigns(:campaign).should equal(mock_campaign)
      end

      it "should re-render the 'edit' template" do
        Campaign.stub!(:find).and_return(mock_campaign(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested campaign" do
      Campaign.should_receive(:find).with("37").and_return(mock_campaign)
      mock_campaign.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the campaigns list" do
      Campaign.stub!(:find).and_return(mock_campaign(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(campaigns_url)
    end

  end

end
