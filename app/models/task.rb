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
  named_scope :overdue,       lambda { { :conditions => [ "due_at < ? AND due_at != ?", Date.today, ASAP ], :order => "due_at, id" } }
  named_scope :due_today,     lambda { { :conditions => [ "due_at = ?", Date.today ] } }
  named_scope :due_tomorrow,  lambda { { :conditions => [ "due_at = ?", Date.tomorrow ] } }
  named_scope :due_this_week, lambda { { :conditions => [ "due_at > ? AND (due_at BETWEEN ? AND ?)", Date.tomorrow, [Date.tomorrow + 1.day, Date.today.end_of_week].min, [Date.tomorrow + 1.day, Date.today.end_of_week].max ], :order => "due_at, id" } }
  named_scope :due_next_week, lambda { { :conditions => [ "due_at BETWEEN ? AND ?", Date.today.end_of_week + 7.days, Date.today.end_of_week + 14.days ], :order => "due_at, id" } }
  named_scope :due_later,     lambda { { :conditions => [ "due_at IS NULL OR due_at > ?", Date.today.end_of_week + 14.days ] } }
  named_scope :due_asap,      :conditions => [ "due_at = ?", ASAP ]
  named_scope :pending,       :conditions => "completed_at IS NULL"
  named_scope :assigned,      :conditions => "assigned_to IS NOT NULL", :include => :assignee
  named_scope :completed,     :conditions => "completed_at IS NOT NULL"

  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :user_id
  validates_presence_of :name, :message => "^Please specify task name."
end
