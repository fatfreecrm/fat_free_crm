# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
          has_many :permissions, as: :asset

          scope :my, lambda {
            accessible_by(User.current_ability)
          }

          include FatFreeCRM::Permissions::InstanceMethods
          extend FatFreeCRM::Permissions::SingletonMethods
        end
      end
    end

    module InstanceMethods
      # Save shared permissions to the model, if any.
      #--------------------------------------------------------------------------
      %w(group user).each do |model|
        class_eval %{

          def #{model}_ids=(value)
            if access != 'Shared'
              remove_permissions
            else
              value = value.flatten.reject(&:blank?).uniq.map(&:to_i)
              permissions_to_remove = Permission.where(
                #{model}_id: self.#{model}_ids - value,
                asset_id: self.id,
                asset_type: self.class
              )
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
        if id && self.class
          permissions_to_remove = Permission.where(asset_id: id, asset_type: self.class.to_s).to_a
        else
          permissions_to_remove = []
        end

        permissions_to_remove.each { |p| permissions.delete(p); p.destroy }
      end

      # Save the model along with its permissions if any.
      #--------------------------------------------------------------------------
      def save_with_permissions(_users = nil)
        ActiveSupport::Deprecation.warn "save_with_permissions is deprecated and may be removed from future releases, use user_ids and group_ids inside attributes instead."
        save
      end

      # Update the model along with its permissions if any.
      #--------------------------------------------------------------------------
      def update_with_permissions(attributes, _users = nil)
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
