# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class LeadObserver < ActiveRecord::Observer
  observe :lead

  @@leads = {}

  def before_update(item)
    @@leads[item.id] = Lead.find(item.id).freeze
  end

  def after_update(item)
    original = @@leads.delete(item.id)
    if original&.status != "rejected" && item.status == "rejected"
      return log_activity(item, :reject)
    end
  end

  private

  def log_activity(item, event)
    item.send(item.class.versions_association_name).create(event: event, whodunnit: PaperTrail.whodunnit)
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_lead_observer, self)
end
