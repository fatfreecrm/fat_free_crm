require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LeadsController do

  before(:each) do
    require_user
    set_current_tab(:leads)
    @uuid = "12345678-0123-5678-0123-567890123456"
  end

  def mock_lead(stubs = { :user => mock_model(User) } )
    @mock_lead ||= mock_model(Lead, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all leads as @leads" do
      Lead.should_receive(:find).with(:all, :order => "id DESC").and_return([mock_lead])
      get :index
      assigns[:leads].should == [mock_lead]
    end

    describe "with mime type of xml" do
  
      it "should render all leads as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Lead.should_receive(:find).with(:all, :order => "id DESC").and_return(leads = mock("Array of Leads"))
        leads.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested lead as @lead" do
      Lead.should_receive(:find).with(@uuid).and_return(mock_lead)
      get :show, :id => @uuid
      assigns[:lead].should equal(mock_lead)
    end
    
    describe "with mime type of xml" do

      it "should render the requested lead as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Lead.should_receive(:find).with(@uuid).and_return(mock_lead)
        mock_lead.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => @uuid
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
      Lead.should_receive(:find).with(@uuid).and_return(mock_lead)
      get :edit, :id => @uuid
      assigns[:lead].should equal(mock_lead)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created lead as @lead" do
        @lead = mock_lead(:save => true)
        @users = [ mock_model(User) ]
        @campaigns = [ mock_model(Campaign) ]

        Lead.should_receive(:new).with({'these' => 'params'}).and_return(@lead)
        User.should_receive(:all_except).with(@current_user).and_return(@users)
        Campaign.should_receive(:find).with(:all, :order => "name").and_return(@campaigns)
        @lead.should_receive(:save_with_permissions).with(%w(1 2 3)).and_return(true)
        @lead.should_receive(:full_name).and_return("Joe Spec")
        post :create, :lead => {:these => 'params'}, :users => %w(1 2 3)
        assigns(:lead).should equal(@lead)
        assigns(:users).should equal(@users)
        assigns(:campaigns).should equal(@campaigns)
      end

      it "should redirect to the created lead" do
        Lead.stub!(:new).and_return(@lead = mock_lead(:save => true))
        @lead.should_receive(:save_with_permissions).with(nil).and_return(true)
        @lead.should_receive(:full_name).and_return("Joe Spec")
        post :create, :lead => {}
        response.should redirect_to(lead_url(mock_lead))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved lead as @lead" do
        @lead = mock_lead(:save => false)
        @users = [ mock_model(User) ]
        @campaigns = [ mock_model(Campaign) ]

        Lead.should_receive(:new).with({'these' => 'params'}).and_return(@lead)
        User.should_receive(:all_except).with(@current_user).and_return(@users)
        Campaign.should_receive(:find).with(:all, :order => "name").and_return(@campaigns)
        @lead.should_receive(:save_with_permissions).with(%w(1 2 3)).and_return(false)
        post :create, :lead => {:these => 'params'}, :users => %w(1 2 3)
        assigns(:lead).should equal(@lead)
        assigns(:users).should equal(@users)
        assigns(:campaigns).should equal(@campaigns)
      end

      it "should re-render the 'new' template" do
        Lead.stub!(:new).and_return(@lead = mock_lead(:save => false))
        @lead.should_receive(:save_with_permissions).with(nil).and_return(false)
        post :create, :lead => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested lead" do
        Lead.should_receive(:find).with(@uuid).and_return(mock_lead)
        mock_lead.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @uuid, :lead => {:these => 'params'}
      end

      it "should expose the requested lead as @lead" do
        Lead.stub!(:find).with(@uuid).and_return(@lead = mock_lead(:update_attributes => true))
        @lead.should_receive(:full_name).and_return("Joe Spec")
        put :update, :id => @uuid
        assigns(:lead).should equal(mock_lead)
      end

      it "should redirect to the lead" do
        Lead.stub!(:find).with(@uuid).and_return(@lead = mock_lead(:update_attributes => true))
        @lead.should_receive(:full_name).and_return("Joe Spec")
        put :update, :id => @uuid
        response.should redirect_to(lead_url(mock_lead))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested lead" do
        Lead.should_receive(:find).with(@uuid).and_return(mock_lead)
        mock_lead.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @uuid, :lead => {:these => 'params'}
      end

      it "should expose the lead as @lead" do
        Lead.stub!(:find).with(@uuid).and_return(mock_lead(:update_attributes => false))
        put :update, :id => @uuid
        assigns(:lead).should equal(mock_lead)
      end

      it "should re-render the 'edit' template" do
        Lead.stub!(:find).with(@uuid).and_return(mock_lead(:update_attributes => false))
        put :update, :id => @uuid
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested lead" do
      Lead.should_receive(:find).with(@uuid).and_return(mock_lead)
      mock_lead.should_receive(:destroy)
      mock_lead.should_receive(:full_name).and_return("Joe Spec")
      delete :destroy, :id => @uuid
    end
  
    it "should redirect to the leads list" do
      Lead.stub!(:find).with(@uuid).and_return(mock_lead(:destroy => true))
      mock_lead.should_receive(:full_name).and_return("Joe Spec")
      delete :destroy, :id => @uuid
      response.should redirect_to(leads_url)
    end

  end

end
