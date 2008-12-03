require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do

  def mock_lead(stubs={})
    @mock_lead ||= mock_model(Lead, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all leads as @leads" do
      Lead.should_receive(:find).with(:all).and_return([mock_lead])
      get :index
      assigns[:leads].should == [mock_lead]
    end

    describe "with mime type of xml" do
  
      it "should render all leads as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Lead.should_receive(:find).with(:all).and_return(leads = mock("Array of Leads"))
        leads.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested lead as @lead" do
      Lead.should_receive(:find).with("37").and_return(mock_lead)
      get :show, :id => "37"
      assigns[:lead].should equal(mock_lead)
    end
    
    describe "with mime type of xml" do

      it "should render the requested lead as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Lead.should_receive(:find).with("37").and_return(mock_lead)
        mock_lead.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new lead as @lead" do
      Lead.should_receive(:new).and_return(mock_lead)
      get :new
      assigns[:lead].should equal(mock_lead)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested lead as @lead" do
      Lead.should_receive(:find).with("37").and_return(mock_lead)
      get :edit, :id => "37"
      assigns[:lead].should equal(mock_lead)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created lead as @lead" do
        Lead.should_receive(:new).with({'these' => 'params'}).and_return(mock_lead(:save => true))
        post :create, :lead => {:these => 'params'}
        assigns(:lead).should equal(mock_lead)
      end

      it "should redirect to the created lead" do
        Lead.stub!(:new).and_return(mock_lead(:save => true))
        post :create, :lead => {}
        response.should redirect_to(lead_url(mock_lead))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved lead as @lead" do
        Lead.stub!(:new).with({'these' => 'params'}).and_return(mock_lead(:save => false))
        post :create, :lead => {:these => 'params'}
        assigns(:lead).should equal(mock_lead)
      end

      it "should re-render the 'new' template" do
        Lead.stub!(:new).and_return(mock_lead(:save => false))
        post :create, :lead => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested lead" do
        Lead.should_receive(:find).with("37").and_return(mock_lead)
        mock_lead.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :lead => {:these => 'params'}
      end

      it "should expose the requested lead as @lead" do
        Lead.stub!(:find).and_return(mock_lead(:update_attributes => true))
        put :update, :id => "1"
        assigns(:lead).should equal(mock_lead)
      end

      it "should redirect to the lead" do
        Lead.stub!(:find).and_return(mock_lead(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(lead_url(mock_lead))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested lead" do
        Lead.should_receive(:find).with("37").and_return(mock_lead)
        mock_lead.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :lead => {:these => 'params'}
      end

      it "should expose the lead as @lead" do
        Lead.stub!(:find).and_return(mock_lead(:update_attributes => false))
        put :update, :id => "1"
        assigns(:lead).should equal(mock_lead)
      end

      it "should re-render the 'edit' template" do
        Lead.stub!(:find).and_return(mock_lead(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested lead" do
      Lead.should_receive(:find).with("37").and_return(mock_lead)
      mock_lead.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the leads list" do
      Lead.stub!(:find).and_return(mock_lead(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(leads_url)
    end

  end

end
