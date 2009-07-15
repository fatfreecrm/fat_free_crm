class Avatar < ActiveRecord::Base
  belongs_to :user
  belongs_to :entity, :polymorphic => true

  # We want to store avatars in separate directories based on entity type
  # (/avatar/User/, /avatars/Lead/, etc.). Therefore use lambda to build target url on the fly.
  has_attached_file :image, :styles => { :icon => "16x16#" }, :url => lambda { |attachment| "/avatars/#{attachment.instance.entity_type}/:id/:style_:filename" }
end
