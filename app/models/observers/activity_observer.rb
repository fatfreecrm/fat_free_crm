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

class ActivityObserver < ActiveRecord::Observer
  observe Account, Campaign, Contact, Lead, Opportunity, Task
  @@tasks = {}
  @@leads = {}
  @@opportunities = {}

  def after_create(subject)
    log_activity(subject, :created)
    if subject.is_a?(Opportunity) && subject.campaign && subject.stage == "won"
      update_campaign_revenue(subject.campaign, (subject.amount || 0) - (subject.discount || 0))
    end
  end

  def before_update(subject)
    if subject.is_a?(Task)
      @@tasks[subject.id] = Task.find_with_destroyed(subject.id).freeze
    elsif subject.is_a?(Lead)
      @@leads[subject.id] = Lead.find_with_destroyed(subject.id).freeze
    elsif subject.is_a?(Opportunity)
      @@opportunities[subject.id] = Opportunity.find_with_destroyed(subject.id).freeze
    end
  end

  def after_update(subject)
    if subject.is_a?(Task)
      original = @@tasks.delete(subject.id)
      if original
        return log_activity(subject, :completed)   if subject.completed_at && original.completed_at.nil?
        return log_activity(subject, :reassigned)  if subject.assigned_to != original.assigned_to
        return log_activity(subject, :rescheduled) if subject.bucket != original.bucket
      end
    elsif subject.is_a?(Lead)
      original = @@leads.delete(subject.id)
      if original && original.status != "rejected" && subject.status == "rejected"
        return log_activity(subject, :rejected)
      end
    elsif subject.is_a?(Opportunity)
      original = @@opportunities.delete(subject.id)
      if original
        if original.stage != "won" && subject.stage == "won"    # :other to :won -- add to total campaign revenue.
          update_campaign_revenue(subject.campaign, (subject.amount || 0) - (subject.discount || 0))
          return log_activity(subject, :won)
        elsif original.stage == "won" && subject.stage != "won" # :won to :other -- substract from total campaign revenue.
          update_campaign_revenue(original.campaign, -((original.amount || 0) - (original.discount || 0)))
        end
      end
    end
    log_activity(subject, :updated)
  end

  def after_destroy(subject)
    if subject.deleted_at               # If the record is marked as deleted...
      log_activity(subject, :deleted)   # then log the activity. Otherwise (i.e. the record
    else                                # is actually deleted) wipe out all related activities.
      Activity.delete_all([ 'subject_id = ? AND subject_type = ?', subject.id, subject.class.to_s ])
    end
  end

  private
  def log_activity(subject, action)
    current_user = User.current_user
    Activity.log(current_user, subject, action) if current_user
  end

  def update_campaign_revenue(campaign, revenue)
    campaign.update_attribute(:revenue, (campaign.revenue || 0) + revenue) if campaign
  end

end
