require 'paper_trail'

class Version < ActiveRecord::Base
  attr_accessible :related
  belongs_to :related, :polymorphic => true
  belongs_to :user, :foreign_key => :whodunnit

  scope :default_order,  order('created_at DESC')
  scope :include_events, lambda { |*events| where(:event => events) }
  scope :exclude_events, lambda { |*events| where('event NOT IN (?)', events) }
  scope :for,            lambda { |user| where(:whodunnit => user.id.to_s) }
  scope :group_by_item,  select('MAX(id) AS id').group(:item_id, :item_type).order('MAX(created_at) DESC').limit(100)
  scope :recent,         where(:id => group_by_item.map(&:id)).where(:item_type => %w(Account Campaign Contact Lead Opportunity)).default_order.limit(10)

  ASSETS   = %w(all tasks campaigns leads accounts contacts opportunities comments emails)
  EVENTS   = %w(all_events create view update destroy)
  DURATION = %w(one_hour one_day two_days one_week two_weeks one_month)
  ENTITIES = %w(Account Campaign Contact Lead Opportunity)

  class << self

    def latest(options = {})
      includes(:item, :related, :user).
      where(({:item_type => options[:asset]} if options[:asset])).
      where(({:event     => options[:event]} if options[:event])).
      where(({:whodunnit => options[:user]}  if options[:user])).
      where('versions.created_at >= ?', Time.zone.now - (options[:duration] || 2.days)).
      default_order
    end

    def related_to(object)
      where('(item_id = :id AND item_type = :type) OR (related_id = :id AND related_type = :type)',
        :id => object.id, :type => object.class.name)
    end

    def history(object)
      related_to(object).exclude_events(:view).default_order
    end

    def visible_to(user)
      scoped.delete_if do |version|
        is_private = false

        item = version.item || version.reify || version.next.reify
        if item.respond_to?(:access) # NOTE: Tasks don't have :access as of yet.
          is_private = item.user_id != user.id && item.assigned_to != user.id &&
            (item.access == "Private" || (item.access == "Shared" && !item.permissions.map(&:user_id).include?(user.id)))
        end
        is_private
      end
    end

  end
end
