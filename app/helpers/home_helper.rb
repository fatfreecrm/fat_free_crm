# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module HomeHelper
  def sort_by_assets
    Version::ASSETS.map do |asset|
      %[{ name: "#{t(asset.singularize)}", on_select: function() { #{redraw(:asset, [asset, t(asset.singularize).downcase], url_for(action: :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_events
    Version::EVENTS.map do |event|
      %[{ name: "#{t(event + '_past_participle')}", on_select: function() { #{redraw(:event, [event, t(event + '_past_participle').downcase], url_for(action: :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_duration
    Version::DURATION.map do |duration|
      %[{ name: "#{t(duration)}", on_select: function() { #{redraw(:duration, [duration, t(duration).downcase], url_for(action: :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_users
    users = [["all_users", t(:option_all_users)]] + @all_users.map do |user|
      escaped = sanitize(user.full_name)
      [escaped, escaped]
    end

    users.map do |key, value|
      %[{ name: "#{value}", on_select: function() { #{redraw(:user, [key, (value == t(:option_all_users) ? value.downcase : value)], url_for(action: :redraw))} } }]
    end
  end

  # Activity title for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def activity_title(activity)
    user    = activity.user.try(:full_name) || ''
    action  = t('action_' + activity.event)
    type    = t('subject_' + activity.item_type.downcase)
    subject = if item = activity.item
                if item.respond_to?(:full_name)
                  item.full_name
                elsif item.respond_to?(:name)
                  item.name
                end
    end
    t(:activity_text, user: user, action: action, type: type, subject: subject,
                      default: "#{user} #{action} #{type} #{subject}")
  end

  # Displays 'not showing' message for a given count, entity and limit
  def show_hidden_entities_message(count, entity, limit = 10)
    if count > limit
      hidden_count = count - 10
      entity_string = I18n.t("#{hidden_count == 1 ? entity : entity.pluralize}_small")
      content_tag(:p) do
        t(:not_showing_hidden_entities, entity: entity_string, count: hidden_count)
      end
    end
  end
end
