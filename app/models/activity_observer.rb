class ActivityObserver < ActiveRecord::Observer
  observe Account, Campaign, Contact, Lead, Opportunity, Task

  def after_create(subject)
    log_activity(subject, :created)
  end

  def after_update(subject)
    log_activity(subject, :updated)
  end

  def after_destroy(subject)
    log_activity(subject, :deleted)
  end

  private
  def log_activity(subject, action)
    authentication = Authentication.find
    if authentication
      current_user = authentication.record
      Activity.log(current_user, subject, action) if current_user
    end
  end
end
