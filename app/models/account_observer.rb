class AccountObserver < ActiveRecord::Observer
  
  def after_create(account)
    UserMailer.deliver_assigned_to_account_notification(account) if account.assigned_to.present?
  end
end
