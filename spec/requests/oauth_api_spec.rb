# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "OAuth API Verification", type: :request do
  let(:user) { create(:user) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:token) { create(:oauth_access_token, resource_owner_id: user.id, application: application, scopes: "api") }

  it "allows access to accounts.json with a valid token in params" do
    create(:account, user: user)

    get "/accounts.json", params: { access_token: token.token }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json).to be_an(Array)
  end

  it "allows access to accounts.json with a valid token in headers" do
    create(:account, user: user)

    get "/accounts.json", headers: { "Authorization" => "Bearer #{token.token}" }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json).to be_an(Array)
  end

  it "denies access to accounts.json without a token" do
    get "/accounts.json"
    # Devise will redirect to login page for HTML requests, but for JSON it should be unauthorized
    expect(response).to have_http_status(:unauthorized)
  end

  it "denies access to accounts.json with an invalid token in params" do
    get "/accounts.json", params: { access_token: "invalid-token" }
    expect(response).to have_http_status(:unauthorized)
  end
end
