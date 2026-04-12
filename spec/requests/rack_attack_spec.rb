# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Rack::Attack" do
  include ActiveSupport::Testing::TimeHelpers

  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  describe "throttle devise/ip" do
    let(:limit) { 5 }

    context "when number of requests is under the limit" do
      it "returns 200 OK" do
        limit.times do
          post user_session_path, params: { user: { email: "test@example.com", password: "password" } }
          expect(response).not_to have_http_status(:too_many_requests)
        end
      end
    end

    context "when number of requests is over the limit" do
      it "returns 429 Too Many Requests" do
        (limit + 1).times do |i|
          post user_session_path, params: { user: { email: "test@example.com", password: "password" } }
          if i < limit
            expect(response).not_to have_http_status(:too_many_requests)
          else
            expect(response).to have_http_status(:too_many_requests)
            expect(response.body).to eq("Too Many Requests\n")
          end
        end
      end
    end

    context "when requests are not POST to /users" do
      it "does not throttle" do
        (limit + 1).times do
          get root_path
          expect(response).not_to have_http_status(:too_many_requests)
        end
      end
    end
  end
end
