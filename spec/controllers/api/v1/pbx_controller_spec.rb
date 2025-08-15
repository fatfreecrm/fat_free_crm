# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::PbxController do
  let(:user) { create(:user, authentication_token: 'token') }
  let(:contact) { create(:contact, phone: '123-456-7890', email: 'test@example.com') }

  def set_token_auth_header(token)
    request.headers['Authorization'] = "Token token=#{token}"
  end

  describe "GET #lookup_contact" do
    context "with valid authentication" do
      before { set_token_auth_header(user.authentication_token) }

      it "returns the contact by phone number" do
        get :lookup_contact, params: { phone_number: contact.phone }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(contact.id)
      end

      it "returns the contact by email" do
        get :lookup_contact, params: { email: contact.email }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(contact.id)
      end

it 'returns not found for a non-existent phone number' do
  get :lookup_contact, params: { phone_number: '999-999-9999' }
  expect(response).to have_http_status(:not_found)
end


      it "returns not found for a non-existent email" do
        get :lookup_contact, params: { email: 'nonexistent@example.com' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "without valid authentication" do
      it "returns unauthorized" do
        get :lookup_contact, params: { phone_number: contact.phone }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #journal_call" do
    let(:note) { 'This is a test note.' }

    context "with valid authentication" do
      before { set_token_auth_header(user.authentication_token) }

      it "creates a new comment for the contact" do
        expect do
          post :journal_call, params: { phone_number: contact.phone, note: note }
        end.to change(Comment, :count).by(1)
        expect(response).to have_http_status(:ok)
      end

      it "returns not found for a non-existent phone number" do
        post :journal_call, params: { phone_number: '999-999-9999', note: note }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "without valid authentication" do
      it "returns unauthorized" do
        post :journal_call, params: { phone_number: contact.phone, note: note }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
