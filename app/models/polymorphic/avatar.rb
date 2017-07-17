# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: avatars
#
#  id                 :integer         not null, primary key
#  user_id            :integer
#  entity_id          :integer
#  entity_type        :string(255)
#  image_file_size    :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Avatar < ActiveRecord::Base
  STYLES = { large: "75x75#", medium: "50x50#", small: "25x25#", thumb: "16x16#" }.freeze

  belongs_to :user
  belongs_to :entity, polymorphic: true

  # We want to store avatars in separate directories based on entity type
  # (i.e. /avatar/User/, /avatars/Lead/, etc.), so we are adding :entity_type
  # interpolation to the Paperclip::Interpolations module.  Also, Paperclip
  # doesn't seem to care preserving styles hash so we must use STYLES.dup.
  #----------------------------------------------------------------------------
  Paperclip::Interpolations.module_eval do
    def entity_type(attachment, _style_name = nil)
      attachment.instance.entity_type
    end
  end
  has_attached_file :image, styles: STYLES.dup, url: "/avatars/:entity_type/:id/:style_:filename", default_url: "/assets/avatar.jpg"
  validates_attachment :image, presence: true,
                               content_type: { content_type: %w(image/jpeg image/jpg image/png image/gif) }

  # Convert STYLE symbols to 'w x h' format for Gravatar and Rails
  # e.g. Avatar.size_from_style(:size => :large) -> '75x75'
  # Allow options to contain :width and :height override keys
  #----------------------------------------------------------------------------
  def self.size_from_style!(options)
    if options[:width] && options[:height]
      options[:size] = [:width, :height].map { |d| options[d] }.join("x")
      options.delete(:width)
      options.delete(:height)
    elsif Avatar::STYLES.keys.include?(options[:size])
      options[:size] = Avatar::STYLES[options[:size]].sub(/\#\z/, '')
    end
    options
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_avatar, self)
end
