# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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
# Schema version: 23
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)
#  commentable_id   :integer(4)
#  commentable_type :string(255)
#  private          :boolean(1)
#  title            :string(255)     default("")
#  comment          :text
#  created_at       :datetime
#  updated_at       :datetime
#
class Comment < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :commentable, :polymorphic => true
  has_many    :activities, :as => :subject, :order => 'created_at DESC'

  default_scope :order => "created_at DESC"
  named_scope :created_by, lambda { |user| { :conditions => ["user_id = ? ", user.id ] } }

  validates_presence_of :user_id, :commentable_id, :commentable_type, :comment
  after_create :log_activity

  private
  def log_activity
    authentication = Authentication.find
    if authentication
      current_user = authentication.record
      Activity.log(current_user, commentable, :commented) if current_user
    end
  end

end
