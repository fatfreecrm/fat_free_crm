# == Schema Information
# Schema version: 15
#
# Table name: tasks
#
#  id          :integer(4)      not null, primary key
#  uuid        :string(36)
#  user_id     :integer(4)
#  assigned_to :integer(4)
#  name        :string(255)     default(""), not null
#  asset_id    :integer(4)
#  asset_type  :string(255)
#  priority    :string(32)
#  status      :string(32)
#  due_at      :datetime
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :asset, :polymorphic => true

  uses_mysql_uuid
  acts_as_paranoid

  validates_presence_of :user_id
  validates_presence_of :name, :message => "^Please specify task name."
end
