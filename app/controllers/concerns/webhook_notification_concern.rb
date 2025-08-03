# frozen_string_literal: true

require 'action_hook'

module WebhookNotificationConcern
  extend ActiveSupport::Concern
  include ActionHook::Hook::On

  on :'fat_free_crm.account.created',
     :'fat_free_crm.account.updated',
     :'fat_free_crm.account.destroyed',
     :'fat_free_crm.campaign.created',
     :'fat_free_crm.campaign.updated',
     :'fat_free_crm.campaign.destroyed',
     :'fat_free_crm.contact.created',
     :'fat_free_crm.contact.updated',
     :'fat_free_crm.contact.destroyed',
     :'fat_free_crm.lead.created',
     :'fat_free_crm.lead.updated',
     :'fat_free_crm.lead.destroyed',
     :'fat_free_crm.task.created',
     :'fat_free_crm.task.updated',
     :'fat_free_crm.task.destroyed' do |payload|
    WebhookTarget.where(enabled: true).each do |target|
      # In a real application, you'd want to handle this asynchronously
      # and add some error handling.
      # For now, we'll just send it synchronously.
      begin
        response = HTTParty.post(
          target.url,
          body: payload.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        if response.success?
          target.update(last_success_at: Time.current)
        end
      rescue StandardError => e
        Rails.logger.error "Failed to send webhook to #{target.url}: #{e.message}"
      end
    end
  end

  private

  def fire_webhook(object, action)
    class_name = object.class.name.downcase
    event_name = "fat_free_crm.#{class_name}.#{action}"

    ActionHook.trigger(
      event_name,
      class: object.class.name,
      id: object.id,
      action: action,
      updated_at: object.updated_at,
      link: url_for(object),
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.full_name
      }
    )
  end
end
