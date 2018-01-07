# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class EntityObserver < ActiveRecord::Observer
  observe :account, :contact, :lead, :opportunity

  def after_create(item)
    send_notification_to_assignee(item) if current_user != item.assignee
  end

  def after_update(item)
    if item.saved_change_to_assigned_to? && item.assignee != current_user
      send_notification_to_assignee(item)
    end
  end

  private

  def send_notification_to_assignee(item)
    if item.assignee.present? && current_user.present? && can_send_email?
      UserMailer.assigned_entity_notification(item, current_user).deliver_now
    end
  end

  # Need to have a host set before email can be sent
  def can_send_email?
    Setting.host.present?
  end

  def current_user
    # this deals with whodunnit inconsistencies, where in some cases it's set to a user's id and others the user object itself
    user_id_or_user = PaperTrail.whodunnit
    if user_id_or_user.is_a?(User)
      user_id_or_user
    elsif user_id_or_user.is_a?(String)
      User.find_by_id(user_id_or_user.to_i)
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_entity_observer, self)
end
