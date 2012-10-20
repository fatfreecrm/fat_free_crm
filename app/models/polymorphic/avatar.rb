# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

  STYLES = { :large => "75x75#", :medium => "50x50#", :small => "25x25#", :thumb => "16x16#" }.freeze

  belongs_to :user
  belongs_to :entity, :polymorphic => true

  # We want to store avatars in separate directories based on entity type
  # (i.e. /avatar/User/, /avatars/Lead/, etc.), so we are adding :entity_type
  # interpolation to the Paperclip::Interpolations module.  Also, Paperclip
  # doesn't seem to care preserving styles hash so we must use STYLES.dup.
  #----------------------------------------------------------------------------
  Paperclip::Interpolations.module_eval do
    def entity_type(attachment, style_name = nil)
      attachment.instance.entity_type
    end
  end
  has_attached_file :image, :styles => STYLES.dup, :url => "/avatars/:entity_type/:id/:style_:filename", :default_url => "/assets/avatar.jpg"

  # Convert STYLE symbols to 'w x h' format for Gravatar and Rails
  # e.g. Avatar.size_from_style(:size => :large) -> '75x75'
  # Allow options to contain :width and :height override keys
  #----------------------------------------------------------------------------
  def self.size_from_style!(options)
    if options[:width] && options[:height]
      options[:size] = [:width, :height].map{|d| options[d]}.join("x") 
    elsif Avatar::STYLES.keys.include?(options[:size])
      options[:size] = Avatar::STYLES[options[:size]].sub(/\#$/,'')
    end
    options
  end

end
