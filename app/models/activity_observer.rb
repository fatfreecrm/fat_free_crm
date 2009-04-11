class ActivityObserver < ActiveRecord::Observer
  observe Account, Campaign, Comment, Contact, Lead, Opportunity, Task

  def after_create(subject)
    stamp(subject, :created)
  end

  def after_update(subject)
    subject.logger.p "self: " + self.methods.sort.inspect
    stamp(subject, :updated)
  end

  def after_destroy(subject)
    stamp(subject, :deleted)
  end

  private
  def stamp(subject, action)
    current_user = Authentication.find.record
    Activity.stamp(current_user, subject, action) if current_user
  end
end
