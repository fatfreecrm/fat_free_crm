require 'paper_trail'

class Version < ActiveRecord::Base
  attr_accessible :related
  belongs_to :related, :polymorphic => true
  belongs_to :user, :foreign_key => :whodunnit

  scope :recent,         where(:event => 'view').order('created_at DESC').limit(10)
  scope :for,            lambda { |user| where(:whodunnit => user.id.to_s) }
  scope :with_events,    lambda { |*events| where('event IN (?)',     events) }
  scope :without_events, lambda { |*events| where('event NOT IN (?)', events) }

  ASSETS   = %w(all tasks campaigns leads accounts contacts opportunities comments emails)
  ACTIONS  = %w(all_actions create view update delete)
  DURATION = %w(one_hour one_day two_days one_week two_weeks one_month)

  def self.latest(options)
    includes(:item, :related, :user).
    where(options[:asset]  ? {:item_type  => options[:asset]}  : nil).
    where(options[:action] ? {:event      => options[:action]} : nil).
    where(options[:user]   ? {:whodunnit  => options[:user].to_s} : nil).
    where('versions.created_at >= ?', Time.zone.now - (options[:duration] || 2.days)).
    order('versions.created_at DESC')
  end

  def self.visible_to(user)
    scoped.delete_if do |version|
      is_private = false

      item = version.item || version.reify
      if item.respond_to?(:access) # NOTE: Tasks don't have :access as of yet.
        is_private = item.user_id != user.id && item.assigned_to != user.id &&
          (item.access == "Private" || (item.access == "Shared" && !item.permissions.map(&:user_id).include?(user.id)))
      end
      is_private
    end
  end

  def self.history(object)
    where("(item_id = :id AND item_type = :type) OR (related_id = :id AND related_type = :type)", :id => object.id, :type => object.class.name).
    order('created_at DESC')
  end
end
