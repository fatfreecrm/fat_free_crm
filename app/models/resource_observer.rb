class ResourceObserver < ActiveRecord::Observer
  observe :account, :lead, :opportunity, :contact
  
  def after_create(resource)
    deliver_notification_if_assigned_to_user(resource)
  end

  def after_update(resource)
    deliver_notification_if_reassigned_to_user(resource)
  end
  
  private

  def deliver_notification_if_assigned_to_user(resource)
    assigner = resource.last_updater || resource.user
    UserMailer.send("deliver_assigned_to_#{resource.class.name.downcase}_email_notification", resource) if resource.assignee.present? && (assigner != resource.assignee)
  end
  
  def deliver_notification_if_reassigned_to_user(resource)
    assigner = resource.last_updater || resource.user
    UserMailer.send("deliver_assigned_to_#{resource.class.name.downcase}_email_notification", resource) if resource.changed.include?("assigned_to") && resource.assignee.present? && (assigner != resource.assignee)
  end
  
end