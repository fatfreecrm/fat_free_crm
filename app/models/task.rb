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
  belongs_to :user
  belongs_to :asset, :polymorphic => true
  named_scope :overdue,       :conditions => [ "due_at < ?", Date.today ], :order => "due_at, id"
  named_scope :due_today,     :conditions => [ "due_at = ?", Date.today ]
  named_scope :due_tomorrow,  :conditions => [ "due_at = ?", Date.tomorrow ]
  named_scope :due_this_week, :conditions => [ "due_at BETWEEN ? AND ?", Date.tomorrow, Date.tomorrow ]
  named_scope :due_next_week, :conditions => [ "due_at BETWEEN ? AND ?", Date.tomorrow, Date.tomorrow ]
  named_scope :due_later,     :conditions => "due_at IS NULL"

  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :user_id
  validates_presence_of :name, :message => "^Please specify task name."
end
