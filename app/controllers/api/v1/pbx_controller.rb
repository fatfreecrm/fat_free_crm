# frozen_string_literal: true

class Api::V1::PbxController < ApplicationController
  before_action :authenticate_api_user!

  def lookup_contact
    if params[:phone_number].present?
      @contact = Contact.where("phone = ? OR mobile = ?", params[:phone_number], params[:phone_number]).first
    elsif params[:email].present?
      @contact = Contact.where("email = ? OR alt_email = ?", params[:email], params[:email]).first
    end

    if @contact
      render json: @contact
    else
      render json: { message: 'Contact not found.' }, status: :not_found
    end
  end

  def journal_call
    if params[:phone_number].present?
      @contact = Contact.where("phone = ? OR mobile = ?", params[:phone_number], params[:phone_number]).first
    elsif params[:email].present?
      @contact = Contact.where("email = ? OR alt_email = ?", params[:email], params[:email]).first
    end

    if @contact
      @contact.comments.create(user: current_user, comment: params[:note])
      render json: { message: 'Call journaled successfully.' }
    else
      render json: { message: 'Contact not found.' }, status: :not_found
    end
  end

  private

  def authenticate_api_user!
    # This is a simple token-based authentication.
    # In a real-world application, you would want to use a more secure authentication method.
    authenticate_or_request_with_http_token do |token, _options|
      User.find_by(authentication_token: token)
    end
  end
end
