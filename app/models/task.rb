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
  ASAP = '1992-10-10 12:30:00'.to_time
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
  named_scope :due_this_week, lambda { { :conditions => [ "due_at >= ? AND due_at < ?", Date.tomorrow + 1.day, Date.today.end_of_week + 1.day ], :order => "due_at, id" } }
  named_scope :due_next_week, lambda { { :conditions => [ "due_at >= ? AND due_at < ?", Date.today.end_of_week + 1.day, Date.today.end_of_week + 8.days ], :order => "due_at, id" } }
  named_scope :due_later,     lambda { { :conditions => [ "due_at IS NULL OR due_at >= ?", Date.today.end_of_week + 8.days ] } }
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

  # Returns filtered list of tasks as required by tasks/index.
  #----------------------------------------------------------------------------
  def self.list(user, view, filters)
    filters = (filters ? filters.split(",").map(&:intern) : [])

    tasks = case view
      when "completed"
        Setting.task_completed.inject({}) { |hash, (value, key)| hash[key] = my(user).send(key).completed if filters.include?(key); hash }
      when "assigned"
        Setting.task_due_date.inject({})  { |hash, (value, key)| hash[key] = assigned_by(user).send(key).pending if filters.include?(key); hash }
      else # "pending"
        Setting.task_due_date.inject({})  { |hash, (value, key)| hash[key] = my(user).send(key).pending if filters.include?(key); hash }
    end
  end

end
