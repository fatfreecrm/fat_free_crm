# Table name: permissions
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  asset_id   :integer(4)
#  asset_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :asset, :polymorphic => true

  validates_presence_of :user_id
end
