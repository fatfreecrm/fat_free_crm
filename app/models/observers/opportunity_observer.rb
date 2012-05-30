# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class OpportunityObserver < ActiveRecord::Observer
  observe :opportunity

  @@opportunities = {}

  def after_create(item)
    if item.campaign && item.stage == "won"
      update_campaign_revenue(item.campaign, (item.amount || 0) - (item.discount || 0))
    end
  end

  def before_update(item)
    @@opportunities[item.id] = Opportunity.find(item.id).freeze
  end

  def after_update(item)
    original = @@opportunities.delete(item.id)
    if original
      if original.stage != "won" && item.stage == "won"    # :other to :won -- add to total campaign revenue.
        update_campaign_revenue(item.campaign, (item.amount || 0) - (item.discount || 0))
        item.update_attribute(:probability, 100) # Set probability to 100% if won
        return log_activity(item, :won)
      elsif original.stage == "won" && item.stage != "won" # :won to :other -- substract from total campaign revenue.
        update_campaign_revenue(original.campaign, -((original.amount || 0) - (original.discount || 0)))
      elsif original.stage != "lost" && item.stage == "lost"
        item.update_attribute(:probability, 0)   # Set probability to 0% if lost
      end
    end
  end

  private

  def log_activity(item, event)
    item.send(item.class.versions_association_name).create(:event => event, :whodunnit => PaperTrail.whodunnit)
  end

  def update_campaign_revenue(campaign, revenue)
    campaign.update_attribute(:revenue, (campaign.revenue || 0) + revenue) if campaign
  end
end
