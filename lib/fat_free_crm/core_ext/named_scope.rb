# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class ActiveRecord::NamedScope::Scope

  # The following is used to filter out user activities based on activity
  # subject's permissions. For example:
  # 
  # @current_user = User.find(1)
  # @activities = Activity.latest.execpt(:viewed).visible_to(@current_user)
  #
  # Note that we can't use named scope for the Activity since the join table
  # name is based on subject type, which is polymorphic.
  #----------------------------------------------------------------------------
  def visible_to(user)
    delete_if do |item|
      is_private = false
      if item.is_a?(Activity)
        subject = item.subject || item.subject_type.constantize.find_with_deleted(item.subject_id)
        if subject.respond_to?(:access) # NOTE: Tasks don't have :access as of yet.
          is_private = subject.user_id != user.id && subject.assigned_to != user.id &&
            (subject.access == "Private" || (subject.access == "Shared" && !subject.permissions.map(&:user_id).include?(user.id)))
        end
      end
      is_private
    end
  end

end
