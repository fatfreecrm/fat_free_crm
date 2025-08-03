# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  before_action :verify_ip

  def readai_meeting_notes
    payload = JSON.parse(request.body.read)
    owner_email = payload.dig("owner", "email")
    user = User.find_by(email: owner_email)

    return head :not_found if user.nil?

    ActiveRecord::Base.transaction do
      payload["participants"].each do |participant|
        participant["email"]
        lead_or_contact = find_or_create_lead_or_contact(participant)

        next unless lead_or_contact

        # Create a Note
        lead_or_contact.notes.create(
          user: user,
          note: "Meeting Summary: #{payload['summary']}\n\nReport URL: #{payload['report_url']}"
        )
      end

      payload["action_items"].each do |action_item|
        Task.create(
          user: user,
          name: action_item["text"],
          assigned_to: user.id
        )
      end
    end

    head :ok
  end

  private

  def find_or_create_lead_or_contact(participant)
    contact = Contact.find_by(email: participant["email"])
    return contact if contact

    lead = Lead.find_by(email: participant["email"])
    return lead if lead

    Lead.create(
      first_name: participant["name"].split.first,
      last_name: participant["name"].split.last,
      email: participant["email"],
      user: User.first # Or assign to a default user
    )
  end

  def verify_ip
    return if request.remote_ip == '127.0.0.1'

    head :unauthorized
  end
end
