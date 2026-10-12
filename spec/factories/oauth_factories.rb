# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    sequence(:name) { |n| "Application #{n}" }
    redirect_uri { "https://example.com/callback" }
    association :owner, factory: :user
  end

  factory :oauth_access_token, class: 'Doorkeeper::AccessToken' do
    association :application, factory: :oauth_application
    resource_owner_id { create(:user).id }
    scopes { "public" }
  end
end
