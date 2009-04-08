class Activity < ActiveRecord::Base

  belongs_to :user
  belongs_to :asset, :polymorphic => true

  validates_presence_of :user, :asset
end
