class Avatar < ActiveRecord::Base
  STYLES = { :large => "75x75#", :medium => "50x50#", :small => "25x25#", :thumb => "16x16#" }.freeze

  belongs_to :user
  belongs_to :entity, :polymorphic => true

  # We want to store avatars in separate directories based on entity type
  # (/avatar/User/, /avatars/Lead/, etc.), so we're using lambda to build
  # target url on the fly. Also, Paperclip doesn't seem to care too much
  # about preserving styles hash, so we must use dup.

  has_attached_file :image, :styles => STYLES.dup, :url => lambda { |attachment| "/avatars/#{attachment.instance.entity_type}/:id/:style_:filename" }, :default_url => "/images/avatar.jpg"


  # Invert STYLES hash removing trailing #.
  #----------------------------------------------------------------------------
  def self.styles
    STYLES.inject({}) { |hash, (key, value)| hash[value[0..-2]] = key; hash }
  end

end
