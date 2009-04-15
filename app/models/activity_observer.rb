class ActivityObserver < ActiveRecord::Observer
  observe Account, Campaign, Comment, Contact, Lead, Opportunity, Task

  def after_create(subject)
    stamp(subject, :created)
  end

  def after_update(subject)
    stamp(subject, :updated)
  end

  def after_destroy(subject)
    stamp(subject, :deleted)
  end

  private
  def stamp(subject, action)
    authentication = Authentication.find
    if authentication
      current_user = authentication.record
      Activity.stamp(current_user, subject, action) if current_user
    end
  end
end
