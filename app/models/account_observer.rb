class AccountObserver < ActiveRecord::Observer
  
  def after_create(account)
    deliver_notification_if_assigned_to_user(account)
  end

  def after_update(account)
    deliver_notification_if_reassigned_to_user(account)
  end
  
  private

  def deliver_notification_if_assigned_to_user(account)
    UserMailer.deliver_assigned_to_account_notification(account) if account.assignee.present?
  end

  def deliver_notification_if_reassigned_to_user(account)
    UserMailer.deliver_assigned_to_account_notification(account) if account.changed.include?("assigned_to") && account.assignee.present?
  end

end
