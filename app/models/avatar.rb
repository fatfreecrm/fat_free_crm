class Avatar < ActiveRecord::Base
  belongs_to :user
  belongs_to :entity, :polymorphic => true
  has_attached_file :image, :styles => { :icon => "16x16#" }, :url => "/avatars/:person/:id/:style_:filename"
end
