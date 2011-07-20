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

module HomeHelper
  def sort_by_assets
    Activity::ASSETS.map do |asset|
      %Q[{ name: "#{t(asset).singularize}", on_select: function() { #{redraw(:asset, [ asset, t(asset).singularize.downcase ], url_for(:action => :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_actions
    Activity::ACTIONS.map do |action|
      %Q[{ name: "#{t(action + '_past_participle')}", on_select: function() { #{redraw(:action_type, [ action, t(action + '_past_participle').downcase ], url_for(:action => :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_duration
    Activity::DURATION.map do |duration|
      %Q[{ name: "#{t(duration)}", on_select: function() { #{redraw(:duration, [ duration, t(duration).downcase ], url_for(:action => :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_users
    users = [[ "all_users", t(:option_all_users) ]] + @all_users.map do |user|
      escaped = escape_javascript(user.full_name)
      [ escaped, escaped ]
    end

    users.map do |key, value|
      %Q[{ name: "#{value}", on_select: function() { #{redraw(:user, [ key, (value == t(:option_all_users) ? value.downcase : value) ], url_for(:action => :redraw))} } }]
    end
  end

  # Activity title for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def activity_title(activity)
    user    = activity.user.full_name
    action  = t('action_' + activity.action)
    type    = t('subject_' + activity.subject_type.downcase)
    subject = if activity.subject
      if activity.subject.respond_to?(:full_name)
        activity.subject.full_name
      else
        activity.subject.name
      end
    else
      activity.info # Use info if the subject has been deleted.
    end
    t(:activity_text, :user => user, :action => action, :type => type, :subject => subject,
      :default => "#{user} #{action} #{type} #{subject}")
  end
end

