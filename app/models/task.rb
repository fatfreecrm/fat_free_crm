# == Schema Information
# Schema version: 16
#
# Table name: tasks
#
#  id           :integer(4)      not null, primary key
#  uuid         :string(36)
#  user_id      :integer(4)
#  assigned_to  :integer(4)
#  name         :string(255)     default(""), not null
#  asset_id     :integer(4)
#  asset_type   :string(255)
#  priority     :string(32)
#  category     :string(32)
#  due_at_hint  :string(32)
#  due_at       :datetime
#  completed_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class Task < ActiveRecord::Base
  attr_accessor :calendar

  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  belongs_to :asset, :polymorphic => true

  # Base scopes to be combined with the due date and completion time.
  named_scope :my,            lambda { |user| { :conditions => [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  named_scope :assigned_by,   lambda { |user| { :conditions => [ "user_id = ? AND assigned_to IS NOT NULL", user.id ], :include => :assignee } }
  named_scope :pending,       :conditions => "completed_at IS NULL", :order => "due_at, id"
  named_scope :assigned,      :conditions => "completed_at IS NULL AND assigned_to IS NOT NULL", :order => "due_at, id"
  named_scope :completed,     :conditions => "completed_at IS NOT NULL", :order => "completed_at DESC"

  # Due date scopes.
  named_scope :due_asap,      :conditions => "due_at IS NULL AND due_at_hint = 'due_asap'", :order => "id DESC"
  named_scope :overdue,       lambda { { :conditions => [ "due_at IS NOT NULL AND due_at < ?", Date.today ], :order => "id DESC" } }
  named_scope :due_today,     lambda { { :conditions => [ "due_at = ?", Date.today ], :order => "id DESC" } }
  named_scope :due_tomorrow,  lambda { { :conditions => [ "due_at = ?", Date.tomorrow ], :order => "id DESC" } }
  named_scope :due_this_week, lambda { { :conditions => [ "due_at >= ? AND due_at < ?", Date.tomorrow + 1.day, Date.today.next_week ], :order => "id DESC" } }
  named_scope :due_next_week, lambda { { :conditions => [ "due_at >= ? AND due_at < ?", Date.today.next_week, Date.today.next_week.end_of_week + 1.day ], :order => "id DESC" } }
  named_scope :due_later,     lambda { { :conditions => [ "(due_at IS NULL AND due_at_hint = 'due_later') OR due_at >= ?", Date.today.next_week.end_of_week + 1.day ], :order => "id DESC" } }

  # Completion time scopes.
  named_scope :completed_today,      lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today, Date.tomorrow ] } }
  named_scope :completed_yesterday,  lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.yesterday, Date.today ] } }
  named_scope :completed_this_week,  lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today.beginning_of_week , Date.yesterday ] } }
  named_scope :completed_last_week,  lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today.beginning_of_week - 7.days, Date.today.beginning_of_week ] } }
  named_scope :completed_this_month, lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today.beginning_of_month, Date.today.beginning_of_week - 7.days ] } }
  named_scope :completed_last_month, lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", (Date.today.beginning_of_month - 1.day).beginning_of_month, Date.today.beginning_of_month ] } }

  uses_mysql_uuid
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :user_id
  validates_presence_of :name, :message => "^Please specify task name."
  validates_presence_of :calendar, :if => "self.due_at_hint == 'specific_time'"
  validate              :specific_time

  before_create :set_due_at, :notify_assignee

  # Convert specific due_date to one of due_today, due_tomorrow, etc. hints.
  #----------------------------------------------------------------------------
  def hint
    return self.due_at_hint if self.due_at_hint != "specific_time"
    case
    when self.due_at < Date.today.to_time
      "overdue"
    when self.due_at == Date.today.to_time
      "due_today"
    when self.due_at == Date.tomorrow.to_time
      "due_tomorrow"
    when self.due_at >= (Date.tomorrow + 1.day).to_time && self.due_at < Date.today.next_week.to_time
      "due_this_week"
    when self.due_at >= Date.today.next_week.to_time && self.due_at < (Date.today.next_week.end_of_week + 1.day).to_time
      "due_next_week"
    else
      "due_later"
    end
  end

  # Returns list of tasks grouping them by due date as required by tasks/index.
  #----------------------------------------------------------------------------
  def self.find_all_grouped(user, view)
    settings = (view == "completed" ? Setting.task_completed : Setting.task_due_at_hint)
    settings.inject({}) do |hash, (value, key)|
      hash[key] = (view == "assigned" ? assigned_by(user).send(key).pending : my(user).send(key).send(view))
      hash
    end
  end

  # Returns bucket if it's empty (i.e. we have to hide it), nil otherwise.
  #----------------------------------------------------------------------------
  def self.bucket(user, bucket, view = "pending")
    return if bucket.blank?
    count = (view == "assigned" ? assigned_by(user).send(bucket).pending.count : my(user).send(bucket).send(view).count)
    count == 0 ? bucket : nil
  end

  # Returns task totals for each of the views as needed by tasks sidebar.
  #----------------------------------------------------------------------------
  def self.totals(user, view = "pending")
    settings = (view == "completed" ? Setting.task_completed : Setting.task_due_at_hint)
    settings.inject({ :all => 0 }) do |hash, (value, key)|
      hash[key] = (view == "assigned" ? assigned_by(user).send(key).pending.count : my(user).send(key).send(view).count)
      hash[:all] += hash[key]
      hash
    end
  end

  private
  #----------------------------------------------------------------------------
  def set_due_at
    self.due_at = case self.due_at_hint
    when "overdue"
      self.due_at || Date.yesterday
    when "due_today"
      Date.today
    when "due_tomorrow"
      Date.tomorrow
    when "due_this_week"
      Date.today.end_of_week
    when "due_next_week"
      Date.today.next_week.end_of_week
    when "due_later"
      Date.today + 100.years
    when "specific_time"
      self.calendar
    else # due_later or due_asap
      nil
    end
  end

  #----------------------------------------------------------------------------
  def specific_time
    if (self.due_at_hint == "specific_time") && (self.calendar !~ %r[\d{2}/\d{2}/\d{4}])
      errors.add(:calendar, "^Please specify valid date.")
    end
  end

  #----------------------------------------------------------------------------
  def notify_assignee
    if self.assigned_to
      # Notify assignee.
    end
  end

end
