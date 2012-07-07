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
            accessible_by(User.current_ability)
          }

          include FatFreeCRM::Permissions::InstanceMethods
          extend  FatFreeCRM::Permissions::SingletonMethods
        end
      end

    end

    module InstanceMethods

      # Save shared permissions to the model, if any.
      #--------------------------------------------------------------------------
      %w(group user).each do |model|
        class_eval %Q{

          def #{model}_ids=(value)
            if access != "Shared"
              remove_permissions
            else
              value.map!{|c| c.split(',')} if value.map{|v| v.to_s.include?(',')}.any? # fix for a bug in "Chosen" which gives values like ["", "1,2,3"] 
              value = value.flatten.reject(&:blank?).uniq.map(&:to_i)
              permissions_to_remove = Permission.find_all_by_#{model}_id_and_asset_id_and_asset_type(self.#{model}_ids - value, self.id, self.class)
              permissions_to_remove.each {|p| (permissions.delete(p); p.destroy)}
              (value - self.#{model}_ids).each {|id| permissions.build(:#{model}_id => id)}
            end
          end

          def #{model}_ids
            permissions.map(&:#{model}_id).compact
          end
        }
      end
      
      # Remove all shared permissions if no longer shared
      #--------------------------------------------------------------------------
      def access=(value)
        remove_permissions unless value == 'Shared'
        super(value)
      end

      # Removes all permissions on an object
      #--------------------------------------------------------------------------
      def remove_permissions
        # we don't use dependent => :destroy so must manually remove
        permissions_to_remove = Permission.find_all_by_asset_id_and_asset_type(self.id, self.class)
        permissions_to_remove.each {|p| (permissions.delete(p); p.destroy)}
      end

      # Save the model along with its permissions if any.
      #--------------------------------------------------------------------------
      def save_with_permissions(users = nil)
        ActiveSupport::Deprecation.warn "save_with_permissions is deprecated and may be removed from future releases, use user_ids and group_ids inside attributes instead."
        save
      end

      # Update the model along with its permissions if any.
      #--------------------------------------------------------------------------
      def update_with_permissions(attributes, users = nil)
        ActiveSupport::Deprecation.warn "update_with_permissions is deprecated and may be removed from future releases, use user_ids and group_ids inside attributes instead."
        update_attributes(attributes)
      end

      # Save the model copying other model's permissions.
      #--------------------------------------------------------------------------
      def save_with_model_permissions(model)
        self.access    = model.access
        self.user_ids  = model.user_ids
        self.group_ids = model.group_ids
        save
      end
      
    end

    module SingletonMethods
    end

  end # Permissions
end # FatFreeCRM

ActiveRecord::Base.send(:include, FatFreeCRM::Permissions)
