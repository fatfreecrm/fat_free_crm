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

module FatFreeCRM
  module Permissions

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def uses_user_permissions
        unless included_modules.include?(InstanceMethods)
          #
          # NOTE: we're deliberately omitting :dependent => :destroy to preserve
          # permissions of deleted objects. This serves two purposes: 1) to be able
          # to implement Recycle Bin/Restore and 2) to honor permissions when
          # displaying "object deleted..." in the activity log.
          #
          has_many :permissions, :as => :asset

          scope :my, lambda {
            current_ability = Ability.new(User.current_user)
            accessible_by(current_ability).readonly(false)
          }

          include FatFreeCRM::Permissions::InstanceMethods
          extend  FatFreeCRM::Permissions::SingletonMethods
        end
      end

    end

    module InstanceMethods

      # Save the model along with its permissions if any.
      #--------------------------------------------------------------------------
      def save_with_permissions(users)
        if users && self[:access] == "Shared"
          users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
        elsif self[:access] == "Private"
          [self.user_id, self.assigned_to].each do |user|
            self.permissions << Permission.new(:user_id => user, :asset => self )
          end
        end
        save
      end

      # Update the model along with its permissions if any.
      #--------------------------------------------------------------------------
      def update_with_permissions(attributes, users)
        if attributes[:access] == "Public"
          self.permissions.delete_all
        elsif attributes[:access] == "Private"
          self.permissions.delete_all
          # If the accessibility is set to Private, it should only be seen by its creator and who it's assigned to
          [attributes[:user_id], attributes[:assigned_to]].each do |user|
            self.permissions << Permission.new(:user_id => user, :asset => self)
          end
        elsif !users.blank? # Check if we have the same users this time around.
          existing_users = self.permissions.map(&:user_id)
          if (existing_users.size != users.size) || (existing_users - users != [])
            self.permissions.delete_all
            users.each do |id|
              self.permissions << Permission.new(:user_id => id, :asset => self)
            end
          end
        end
        update_attributes(attributes)
      end

      # Save the model copying other model's permissions.
      #--------------------------------------------------------------------------
      def save_with_model_permissions(model)
        self.access = model.access
        if model.access == "Shared"
          model.permissions.each do |permission|
            self.permissions << Permission.new(:user_id => permission.user_id, :asset => self)
          end
        end
        save
      end

    end

    module SingletonMethods
    end

  end # Permissions
end # FatFreeCRM

ActiveRecord::Base.send(:include, FatFreeCRM::Permissions)

