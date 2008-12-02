class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :asset, :polymorphic => true

  validates_presence_of :user_id, :asset_id, :asset_type
end
