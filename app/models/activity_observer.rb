class ActivityObserver < ActiveRecord::Observer
  observe Account, Campaign, Comment, Contact, Lead, Opportunity, Task

  def after_create(model)
    # model.logger.p "after_create: " + model.inspect
    create_activity(model, :created)
  end

  def after_update(model)
    # model.logger.p "after_update: " + model.inspect
    create_activity(model, :updated)
  end

  def after_destroy(model)
    # model.logger.p "after_destroy: " + model.inspect
    create_activity(model, :deleted)
  end

  private
  def create_activity(model, action)
    Activity.create(
      :user    => model.user,
      :subject => model,
      :action  => action.to_s,
      :info    => model.respond_to?(:full_name) ? model.full_name : (model.respond_to?(:name) ? model.name : nil)
    )
  end
end
