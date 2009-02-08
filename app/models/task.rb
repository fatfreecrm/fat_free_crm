# == Schema Information
# Schema version: 15
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
#  due_at       :datetime
#  completed_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class Task < ActiveRecord::Base
  ASAP = '1992-10-10 12:30:00'.to_time.localtime
  attr_accessor :due_date, :calendar

  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  belongs_to :asset, :polymorphic => true

  # Base scopes to be combined with the due date and completion time.
  named_scope :my,            lambda { |user| { :conditions => [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  named_scope :assigned_by,   lambda { |user| { :conditions => [ "user_id = ? AND assigned_to IS NOT NULL", user.id ], :include => :assignee } }
  named_scope :pending,       :conditions => "completed_at IS NULL", :order => "due_at, id"
  named_scope :completed,     :conditions => "completed_at IS NOT NULL", :order => "completed_at DESC"

  # Due date scopes.
  named_scope :due_asap,      :conditions => [ "due_at = ?", ASAP ]
  named_scope :due_today,     lambda { { :conditions => [ "due_at = ?", Date.today ] } }
  named_scope :due_tomorrow,  lambda { { :conditions => [ "due_at = ?", Date.tomorrow ] } }
  named_scope :due_this_week, lambda { { :conditions => [ "due_at >= ? AND due_at < ?", Date.tomorrow + 1.day, Date.today.next_week ], :order => "due_at, id" } }
  named_scope :due_next_week, lambda { { :conditions => [ "due_at >= ? AND due_at < ?", Date.today.next_week, Date.today.next_week.end_of_week + 1.day ], :order => "due_at, id" } }
  named_scope :due_later,     lambda { { :conditions => [ "due_at IS NULL OR due_at >= ?", Date.today.next_week.end_of_week + 1.day ] } }
  named_scope :overdue,       lambda { { :conditions => [ "due_at < ? AND due_at != ?", Date.today, ASAP ], :order => "due_at, id" } }

  # Completion time scopes.
  named_scope :completed_today,      lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today, Date.tomorrow ] } }
  named_scope :completed_yesterday,  lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.yesterday, Date.today ] } }
  named_scope :completed_this_week,  lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today.beginning_of_week , Date.yesterday ] } }
  named_scope :completed_last_week,  lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today.beginning_of_week - 7.days, Date.today.beginning_of_week ] } }
  named_scope :completed_this_month, lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", Date.today.beginning_of_month, Date.today.beginning_of_week - 7.days ] } }
  named_scope :completed_last_month, lambda { { :conditions => [ "completed_at >= ? AND completed_at < ?", (Date.today.beginning_of_month - 1.day).beginning_of_month, Date.today.beginning_of_month ] } }

  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :user_id
  validates_presence_of :name, :message => "^Please specify task name."
  before_create :set_due_at, :notify_assignee

  # Returns list of tasks grouping them by due date as required by tasks/index.
  #----------------------------------------------------------------------------
  def self.find_all_grouped(user, view)
    tasks = case view
      when "completed"
        Setting.task_completed.inject({}) { |hash, (value, key)| hash[key] = my(user).send(key).completed; hash }
      when "assigned"
        Setting.task_due_date.inject({})  { |hash, (value, key)| hash[key] = assigned_by(user).send(key).pending; hash }
      else # "pending"
        Setting.task_due_date.inject({})  { |hash, (value, key)| hash[key] = my(user).send(key).pending; hash }
    end
  end

  # Returns bucket if it's empty (i.e. we have to hide it), nil otherwise.
  #----------------------------------------------------------------------------
  def self.bucket(user, bucket, view = "pending")
    count = case view
    when "completed"
      my(user).send(bucket.intern).completed.count
    when "assigned"
      assigned_by(user).send(bucket.intern).pending.count
    else # "pending"
      my(user).send(bucket.intern).pending.count
    end
    count == 0 ? bucket : nil
  end

  # Returns task totals for each of the views as needed by tasks sidebar.
  #----------------------------------------------------------------------------
  def self.totals(user, view = "pending")
    totals = { :all => 0 }
    settings = (view == "completed" ? Setting.task_completed : Setting.task_due_date)
    settings.each do |value, key|
      totals[key] = case view
      when "completed"
        my(user).send(key).completed.count
      when "assigned"
        assigned_by(user).send(key).pending.count
      else # "pending"
        my(user).send(key).pending.count
      end
      totals[:all] += totals[key]
    end
    totals
  end

  private
  #----------------------------------------------------------------------------
  def set_due_at
    logger.debug "\n\ndue_date: " + self.due_date.to_s
    self.due_at = case self.due_date
    when "due_asap"
      ASAP
    when "due_today"
      Date.today
    when "due_tomorrow"
      Date.tomorrow
    when "due_this_week"
      Date.today.end_of_week
    when "due_next_week"
      Date.today.next_week.end_of_week
    when "due_later"
      Date.today + 1.year
    end
  end

  #----------------------------------------------------------------------------
  def notify_assignee
    if self.assigned_to
      # Notify assignee.
    end
  end

end
