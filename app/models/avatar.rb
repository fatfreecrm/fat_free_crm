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
# Schema version: 27
#
# Table name: avatars
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  entity_id          :integer(4)
#  entity_type        :string(255)
#  image_file_size    :integer(4)
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
  has_attached_file :image, :styles => STYLES.dup, :url => "/avatars/:entity_type/:id/:style_:filename", :default_url => "/images/avatar.jpg"

  # Invert STYLES hash removing trailing #.
  #----------------------------------------------------------------------------
  def self.styles
    Hash[STYLES.map{ |key, value| [ value[0..-2], key ] }]
  end
end
