# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'paper_trail'

class Version < PaperTrail::Version
  ASSETS = %w[all tasks campaigns leads accounts contacts opportunities comments emails]
  EVENTS = %w[all_events create view update destroy]
  DURATION = %w[one_hour one_day two_days one_week two_weeks one_month]

  belongs_to :related, polymorphic: true, optional: true # TODO: Is this really optional?
  belongs_to :user, foreign_key: :whodunnit, optional: true # TODO: Is this really optional?

  scope :default_order,  -> { order('created_at DESC') }
  scope :include_events, ->(*events) { where(event: events) }
  scope :exclude_events, ->(*events) { where('event NOT IN (?)', events) }
  scope :for,            ->(user) { where(whodunnit: user.id.to_s) }

  class << self
    def recent_for_user(user, limit = 10)
      # Hybrid SQL/Ruby to build a unique list of the most recent entities that the
      # user has interacted with
      versions = []
      offset = 0
      while versions.size < limit
        query = includes(:item)
                .where(whodunnit: user.id.to_s)
                .where(item_type: ENTITIES)
                .limit(limit * 2)
                .offset(offset)
                .default_order

        break if query.empty?

        versions += query.select { |v| v.item.present? }
        versions.uniq! { |v| [v.item_id, v.item_type] }
        offset += limit * 2
      end
      versions[0...10]
    end

    def latest(options = {})
      includes(:item, :related, :user)
        .where(({ item_type: options[:asset] } if options[:asset]))
        .where(({ event:     options[:event] } if options[:event]))
        .where(({ whodunnit: options[:user].to_s } if options[:user]))
        .where('versions.created_at >= ?', Time.zone.now - (options[:duration] || 2.days))
        .limit(options[:max])
        .default_order
    end

    def related_to(object)
      where('(item_id = :id AND item_type = :type) OR (related_id = :id AND related_type = :type)',
            id: object.id, type: object.class.name)
    end

    def history(object)
      related_to(object).exclude_events(:view).default_order
    end

    def visible_to(user)
      all.to_a.delete_if do |version|
        if item = version.item || version.reify
          if item.respond_to?(:access) # NOTE: Tasks don't have :access as of yet.
            # Delete from scope if it shouldn't be visible
            next item.user_id != user.id &&
              item.assigned_to != user.id &&
              (item.access == "Private" ||
                (item.access == "Shared" &&
                 !item.permissions.map(&:user_id).include?(user.id)))
          end
          # Don't delete any objects that don't have :access method (e.g. tasks)
          next false
        end
        # Delete from scope if no object can be found or reified (e.g. from 'show' events)
        true
      end
    end
  end
end
