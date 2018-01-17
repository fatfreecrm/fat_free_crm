# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: tasks
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  assigned_to     :integer
#  completed_by    :integer
#  name            :string(255)     default(""), not null
#  asset_id        :integer
#  asset_type      :string(255)
#  priority        :string(32)
#  category        :string(32)
#  bucket          :string(32)
#  due_at          :datetime
#  completed_at    :datetime
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

class Task < ActiveRecord::Base
  include ActiveModel::Serializers::Xml

  attr_accessor :calendar
  ALLOWED_VIEWS = %w[pending assigned completed]

  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to
  belongs_to :completor, class_name: "User", foreign_key: :completed_by
  belongs_to :asset, polymorphic: true

  serialize :subscribed_users, Array

  # Tasks created by the user for herself, or assigned to her by others. That's
  # what gets shown on Tasks/Pending and Tasks/Completed pages.
  scope :my, ->(*args) {
    options = args[0] || {}
    user_option = (options.is_a?(Hash) ? options[:user] : options) || User.current_user
    includes(:assignee)
      .where('(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?', user_option, user_option)
      .order(options[:order] || 'name ASC')
      .limit(options[:limit]) # nil selects all records
  }

  scope :created_by,  ->(user) { where(user_id: user.id) }
  scope :assigned_to, ->(user) { where(assigned_to: user.id) }

  # Tasks assigned by the user to others. That's what we see on Tasks/Assigned.
  scope :assigned_by, ->(user) {
    includes(:assignee)
      .where('user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?', user.id, user.id)
  }

  # Tasks created by the user or assigned to the user, i.e. the union of the two
  # scopes above. That's the tasks the user is allowed to see and track.
  scope :tracked_by, ->(user) {
    includes(:assignee)
      .where('user_id = ? OR assigned_to = ?', user.id, user.id)
  }

  # Show tasks which either belong to the user and are unassigned, or are assigned to the user
  scope :visible_on_dashboard, ->(user) {
    where('(user_id = :user_id AND assigned_to IS NULL) OR assigned_to = :user_id', user_id: user.id).where('completed_at IS NULL')
  }

  scope :by_due_at, -> {
    order({
      "MySQL"      => "due_at NOT NULL, due_at ASC",
      "PostgreSQL" => "due_at ASC NULLS FIRST"
    }[ActiveRecord::Base.connection.adapter_name] || :due_at)
  }

  # Status based scopes to be combined with the due date and completion time.
  scope :pending,       -> { where('completed_at IS NULL').order('tasks.due_at, tasks.id') }
  scope :assigned,      -> { where('completed_at IS NULL AND assigned_to IS NOT NULL').order('tasks.due_at, tasks.id') }
  scope :completed,     -> { where('completed_at IS NOT NULL').order('tasks.completed_at DESC') }

  # Due date scopes.
  scope :due_asap,      -> { where("due_at IS NULL AND bucket = 'due_asap'").order('tasks.id DESC') }
  scope :overdue,       -> { where('due_at IS NOT NULL AND due_at < ?', Time.zone.now.midnight.utc).order('tasks.id DESC') }
  scope :due_today,     -> { where('due_at >= ? AND due_at < ?', Time.zone.now.midnight.utc, Time.zone.now.midnight.tomorrow.utc).order('tasks.id DESC') }
  scope :due_tomorrow,  -> { where('due_at >= ? AND due_at < ?', Time.zone.now.midnight.tomorrow.utc, Time.zone.now.midnight.tomorrow.utc + 1.day).order('tasks.id DESC') }
  scope :due_this_week, -> { where('due_at >= ? AND due_at < ?', Time.zone.now.midnight.tomorrow.utc + 1.day, Time.zone.now.next_week.utc).order('tasks.id DESC') }
  scope :due_next_week, -> { where('due_at >= ? AND due_at < ?', Time.zone.now.next_week.utc, Time.zone.now.next_week.end_of_week.utc + 1.day).order('tasks.id DESC') }
  scope :due_later,     -> { where("(due_at IS NULL AND bucket = 'due_later') OR due_at >= ?", Time.zone.now.next_week.end_of_week.utc + 1.day).order('tasks.id DESC') }

  # Completion time scopes.
  scope :completed_today,      -> { where('completed_at >= ? AND completed_at < ?', Time.zone.now.midnight.utc, Time.zone.now.midnight.tomorrow.utc) }
  scope :completed_yesterday,  -> { where('completed_at >= ? AND completed_at < ?', Time.zone.now.midnight.yesterday.utc, Time.zone.now.midnight.utc) }
  scope :completed_this_week,  -> { where('completed_at >= ? AND completed_at < ?', Time.zone.now.beginning_of_week.utc, Time.zone.now.midnight.yesterday.utc) }
  scope :completed_last_week,  -> { where('completed_at >= ? AND completed_at < ?', Time.zone.now.beginning_of_week.utc - 7.days, Time.zone.now.beginning_of_week.utc) }
  scope :completed_this_month, -> { where('completed_at >= ? AND completed_at < ?', Time.zone.now.beginning_of_month.utc, Time.zone.now.beginning_of_week.utc - 7.days) }
  scope :completed_last_month, -> { where('completed_at >= ? AND completed_at < ?', (Time.zone.now.beginning_of_month.utc - 1.day).beginning_of_month.utc, Time.zone.now.beginning_of_month.utc) }

  scope :text_search, ->(query) {
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(name) LIKE upper(?)', "%#{query}%")
  }

  acts_as_commentable
  has_paper_trail class_name: 'Version', meta: { related: :asset },
                  ignore: [:subscribed_users]
  has_fields
  exportable

  validates_presence_of :user
  validates_presence_of :name, message: :missing_task_name
  validates_presence_of :calendar, if: -> { bucket == 'specific_time' && !completed_at }
  validate :specific_time, unless: :completed?

  before_create :set_due_date
  before_update :set_due_date, unless: :completed?
  before_save :notify_assignee

  # Matcher for the :my named scope.
  #----------------------------------------------------------------------------
  def my?(user)
    (self.user == user && assignee.nil?) || assignee == user
  end

  # Matcher for the :assigned_by named scope.
  #----------------------------------------------------------------------------
  def assigned_by?(user)
    self.user == user && assignee && assignee != user
  end

  #----------------------------------------------------------------------------
  def completed?
    !!completed_at
  end

  # Matcher for the :tracked_by? named scope.
  #----------------------------------------------------------------------------
  def tracked_by?(user)
    self.user == user || assignee == user
  end

  # Check whether the due date has specific time ignoring 23:59:59 timestamp
  # set by Time.now.end_of_week.
  #----------------------------------------------------------------------------
  def at_specific_time?
    due_at.present? && !due_end_of_day? && !due_beginning_of_day?
  end

  # Convert specific due_date to "due_today", "due_tomorrow", etc. bucket name.
  #----------------------------------------------------------------------------
  def computed_bucket
    return bucket if bucket != "specific_time"
    if overdue?
      "overdue"
    elsif due_today?
      "due_today"
    elsif due_tomorrow?
      "due_tomorrow"
    elsif due_this_week? && !due_today? && !due_tomorrow?
      "due_this_week"
    elsif due_next_week?
      "due_next_week"
    else
      "due_later"
    end
  end

  # Returns list of tasks grouping them by due date as required by tasks/index.
  #----------------------------------------------------------------------------
  def self.find_all_grouped(user, view)
    return {} unless ALLOWED_VIEWS.include?(view)
    settings = (view == "completed" ? Setting.task_completed : Setting.task_bucket)
    Hash[
      settings.map do |key, _value|
        [key, view == "assigned" ? assigned_by(user).send(key).pending : my(user).send(key).send(view)]
      end
    ]
  end

  # Returns bucket if it's empty (i.e. we have to hide it), nil otherwise.
  #----------------------------------------------------------------------------
  def self.bucket_empty?(bucket, user, view = "pending")
    return false if bucket.blank? || !ALLOWED_VIEWS.include?(view)
    if view == "assigned"
      assigned_by(user).send(bucket).pending.count
    else
      my(user).send(bucket).send(view).count
    end == 0
  end

  # Returns task totals for each of the views as needed by tasks sidebar.
  #----------------------------------------------------------------------------
  def self.totals(user, view = "pending")
    return {} unless ALLOWED_VIEWS.include?(view)
    settings = (view == "completed" ? Setting.task_completed : Setting.task_bucket)
    settings.each_with_object(HashWithIndifferentAccess[all: 0]) do |key, hash|
      hash[key] = (view == "assigned" ? assigned_by(user).send(key).pending.count : my(user).send(key).send(view).count)
      hash[:all] += hash[key]
      hash
    end
  end

  private

  #----------------------------------------------------------------------------
  def set_due_date
    self.due_at = case bucket
                  when "overdue"
                    due_at || Time.zone.now.midnight.yesterday
                  when "due_today"
                    Time.zone.now.midnight
                  when "due_tomorrow"
                    Time.zone.now.midnight.tomorrow
                  when "due_this_week"
                    Time.zone.now.end_of_week
                  when "due_next_week"
                    Time.zone.now.next_week.end_of_week
                  when "due_later"
                    Time.zone.now.midnight + 100.years
                  when "specific_time"
                    calendar ? parse_calendar_date : nil
    end
  end

  #----------------------------------------------------------------------------
  def due_end_of_day?
    due_at.present? && (due_at.change(usec: 0) == due_at.end_of_day.change(usec: 0))
  end

  #----------------------------------------------------------------------------
  def due_beginning_of_day?
    due_at.present? && (due_at == due_at.beginning_of_day)
  end

  #----------------------------------------------------------------------------
  def overdue?
    due_at < Time.zone.now.midnight
  end

  #----------------------------------------------------------------------------
  def due_today?
    due_at.between?(Time.zone.now.midnight, Time.zone.now.end_of_day)
  end

  #----------------------------------------------------------------------------
  def due_tomorrow?
    due_at.between?(Time.zone.now.midnight.tomorrow, Time.zone.now.tomorrow.end_of_day)
  end

  #----------------------------------------------------------------------------
  def due_this_week?
    due_at.between?(Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
  end

  #----------------------------------------------------------------------------
  def due_next_week?
    due_at.between?(Time.zone.now.next_week, Time.zone.now.next_week.end_of_week)
  end

  #----------------------------------------------------------------------------
  def notify_assignee
    if assigned_to
      # Notify assignee.
    end
  end

  #----------------------------------------------------------------------------
  def specific_time
    parse_calendar_date if bucket == "specific_time"
  rescue ArgumentError
    errors.add(:calendar, :invalid_date)
  end

  #----------------------------------------------------------------------------
  def parse_calendar_date
    # always in 2012-10-28 06:28 format regardless of language
    Time.parse(calendar)
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_task, self)
end
