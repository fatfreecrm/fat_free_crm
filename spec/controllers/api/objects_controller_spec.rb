require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

API_USER_ID = Api::ApplicationController::API_USER_ID

describe Api::ObjectsController do

  before(:all) do
    api_user = User.new
    api_user.username = 'api'
    api_user.first_name = 'API'
    api_user.last_name = 'User'
    api_user.email = 'api.user@test.com'
    api_user.password = 'apitest'
    api_user.id = API_USER_ID # force the id so that it lines up with what is in the controller
    api_user.save!
  end

  before(:each) do
    api_user = User.find(API_USER_ID)
    api_key = Digest::SHA256.hexdigest("#{api_user.username}:#{api_user.encrypted_password}")
    request.env['Authorization'] = "Bearer #{api_key}"
  end

  describe "actions" do

    it "does not allow unauthorized users to complete their request" do
      get :show, params: { model: 'leads', id: 1 }
      expect(response).to_not be_success
    end

    it "does not allow querying a model that isn't designated as allowed" do
      expect {
        get :show, params: { model: 'tasks', id: 1 }  
      }.to raise_exception(RuntimeError)
    end

    it "correctly determines the model" do
      get :show, params: { model: 'accounts', id: 1 }
      expect(assigns[:model].to_s).to eq('Account')
    end

  end

  describe "GET show" do

    it "returns the requested object" do
      @account = create(:account)
      get :show, params: { model: 'accounts', id: @account.id }
      expect(assigns[:object].id).to eq(@account.id)
    end

  end

  describe "POST create" do

    it "creates the requested object and returns the object" do
      post :create, params: { model: 'lead', object: { first_name: 'Test', last_name: 'Lead', email: 'test.lead@example.com' } }
      expect(assigns[:object]).to_not be_nil
    end

    it "assigns the API user as the record owner" do
      post :create, params: { model: 'lead', object: { first_name: 'Another', last_name: 'Lead', email: 'another.lead@example.com' } }
      expect(assigns[:object].user_id).to eq(API_USER_ID)
    end

    it "returns an error when there has been an issue creating the object" do
      post :create, params: { model: 'lead', object: { first_name: 'Incomplete' } }
      expect(response).to_not be_success
    end

  end

end
