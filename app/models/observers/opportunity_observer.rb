# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class OpportunityObserver < ActiveRecord::Observer
  observe :opportunity

  @@opportunities = {}

  def after_create(item)
    update_campaign_revenue(item.campaign, item.amount.to_f - item.discount.to_f) if item.campaign && item.stage == "won"
  end

  def before_update(item)
    @@opportunities[item.id] = Opportunity.find(item.id).freeze
  end

  def after_update(item)
    original = @@opportunities.delete(item.id)
    if original
      if original.stage != "won" && item.stage == "won" # :other to :won -- add to total campaign revenue.
        update_campaign_revenue(item.campaign, item.amount.to_f - item.discount.to_f)
        item.update_attribute(:probability, 100) # Set probability to 100% if won
        log_activity(item, :won)
      elsif original.stage == "won" && item.stage != "won" # :won to :other -- substract from total campaign revenue.
        update_campaign_revenue(original.campaign, -(original.amount.to_f - original.discount.to_f))
      elsif original.stage != "lost" && item.stage == "lost"
        item.update_attribute(:probability, 0) # Set probability to 0% if lost
      end
    end
  end

  private

  def log_activity(item, event)
    item.send(item.class.versions_association_name).create(event: event, whodunnit: PaperTrail.request.whodunnit)
  end

  def update_campaign_revenue(campaign, revenue)
    campaign&.update_attribute(:revenue, campaign.revenue.to_f + revenue)
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_opportunity_observer, self)
end
