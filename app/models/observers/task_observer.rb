# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class TaskObserver < ActiveRecord::Observer
  observe :task

  @@tasks = {}

  def before_update(item)
    @@tasks[item.id] = Task.find(item.id).freeze
  end

  def after_update(item)
    original = @@tasks.delete(item.id)
    if original
      return log_activity(item, :complete)   if item.completed_at && original.completed_at.nil?
      return log_activity(item, :reassign)   if item.assigned_to != original.assigned_to
      return log_activity(item, :reschedule) if item.bucket != original.bucket
    end
  end

  private

  def log_activity(item, event)
    item.send(item.class.versions_association_name).create(event: event, whodunnit: PaperTrail.request.whodunnit)
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_task_observer, self)
end
