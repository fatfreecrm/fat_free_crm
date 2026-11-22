require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe CampaignsController, type: :request do
  it "should allow access to RSS feed via authentication_credentials" do
    u = User.create!(username: "testuser", email: "test@example.com", password: "Password123!", password_confirmation: "Password123!", authentication_token: "test_token")
    u.confirm
    create(:campaign, user: u)

    get "/campaigns.rss", params: { authentication_credentials: "test_token" }
    expect(response.status).to eq(200)
    expect(response.media_type).to eq("application/rss+xml")
  end

  it "should fail access to RSS feed with invalid authentication_credentials" do
    get "/campaigns.rss", params: { authentication_credentials: "invalid_token" }
    expect(response.status).to eq(401)
  end

  it "should fail access to RSS feed without authentication_credentials" do
    get "/campaigns.rss"
    expect(response.status).to eq(401)
  end
end
