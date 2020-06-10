# frozen_string_literal: true

module FatFreeCrm
  class IndexCaseObserver < ActiveRecord::Observer
    observe :"FatFreeCrm::IndexCase"

    def after_create(item)
      # send_notification_to_contact(item)
      send_notification_to_manager(item) if item.contact.present?
    end

    # def after_update(item)
    #   send_notification_to_assignee(item) if item.saved_change_to_assigned_to? && item.assignee != current_user
    # end

    private

    def send_notification_to_contact(item)
      UserMailer.index_case_notification_to_contact(item).deliver_now if item.contact.present?
    end

    def send_notification_to_manager(item)
      UserMailer.index_case_notification_to_manager(item).deliver_now
    end

    ActiveSupport.run_load_hooks(:fat_free_crm_index_case_observer, self)
  end
end
