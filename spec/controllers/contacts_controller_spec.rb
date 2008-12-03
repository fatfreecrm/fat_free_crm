require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do

  def mock_contact(stubs={})
    @mock_contact ||= mock_model(Contact, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all contacts as @contacts" do
      Contact.should_receive(:find).with(:all).and_return([mock_contact])
      get :index
      assigns[:contacts].should == [mock_contact]
    end

    describe "with mime type of xml" do
  
      it "should render all contacts as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Contact.should_receive(:find).with(:all).and_return(contacts = mock("Array of Contacts"))
        contacts.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested contact as @contact" do
      Contact.should_receive(:find).with("37").and_return(mock_contact)
      get :show, :id => "37"
      assigns[:contact].should equal(mock_contact)
    end
    
    describe "with mime type of xml" do

      it "should render the requested contact as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Contact.should_receive(:find).with("37").and_return(mock_contact)
        mock_contact.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new contact as @contact" do
      Contact.should_receive(:new).and_return(mock_contact)
      get :new
      assigns[:contact].should equal(mock_contact)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested contact as @contact" do
      Contact.should_receive(:find).with("37").and_return(mock_contact)
      get :edit, :id => "37"
      assigns[:contact].should equal(mock_contact)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created contact as @contact" do
        Contact.should_receive(:new).with({'these' => 'params'}).and_return(mock_contact(:save => true))
        post :create, :contact => {:these => 'params'}
        assigns(:contact).should equal(mock_contact)
      end

      it "should redirect to the created contact" do
        Contact.stub!(:new).and_return(mock_contact(:save => true))
        post :create, :contact => {}
        response.should redirect_to(contact_url(mock_contact))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved contact as @contact" do
        Contact.stub!(:new).with({'these' => 'params'}).and_return(mock_contact(:save => false))
        post :create, :contact => {:these => 'params'}
        assigns(:contact).should equal(mock_contact)
      end

      it "should re-render the 'new' template" do
        Contact.stub!(:new).and_return(mock_contact(:save => false))
        post :create, :contact => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested contact" do
        Contact.should_receive(:find).with("37").and_return(mock_contact)
        mock_contact.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :contact => {:these => 'params'}
      end

      it "should expose the requested contact as @contact" do
        Contact.stub!(:find).and_return(mock_contact(:update_attributes => true))
        put :update, :id => "1"
        assigns(:contact).should equal(mock_contact)
      end

      it "should redirect to the contact" do
        Contact.stub!(:find).and_return(mock_contact(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(contact_url(mock_contact))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested contact" do
        Contact.should_receive(:find).with("37").and_return(mock_contact)
        mock_contact.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :contact => {:these => 'params'}
      end

      it "should expose the contact as @contact" do
        Contact.stub!(:find).and_return(mock_contact(:update_attributes => false))
        put :update, :id => "1"
        assigns(:contact).should equal(mock_contact)
      end

      it "should re-render the 'edit' template" do
        Contact.stub!(:find).and_return(mock_contact(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested contact" do
      Contact.should_receive(:find).with("37").and_return(mock_contact)
      mock_contact.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the contacts list" do
      Contact.stub!(:find).and_return(mock_contact(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(contacts_url)
    end

  end

end
