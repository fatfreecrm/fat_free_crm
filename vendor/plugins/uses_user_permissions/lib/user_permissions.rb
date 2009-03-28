module ActiveRecord
  module Uses
    module User
      module Permissions

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def uses_user_permissions
            unless included_modules.include?(InstanceMethods)
              has_many :permissions, :as => :asset, :include => :user
              named_scope :my, lambda { |user| { :include => :permissions, :conditions => ["#{self.table_name}.user_id=? OR #{self.table_name}.assigned_to=? OR permissions.user_id=?", user, user, user], :order => "#{self.table_name}.id DESC" } }
              include ActiveRecord::Uses::User::Permissions::InstanceMethods
              extend  ActiveRecord::Uses::User::Permissions::SingletonMethods
            end
          end

        end

        module InstanceMethods

          # Save the model along with its permissions if any.
          #--------------------------------------------------------------------------
          def save_with_permissions(users)
            if users && self[:access] == "Shared"
              users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
            end
            save
          end

          # Update the model along with its permissions if any.
          #--------------------------------------------------------------------------
          def update_with_permissions(attributes, users)
            if attributes[:access] != "Shared"
              self.permissions.delete_all
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
    end # User
  end # Uses
end # ActiveRecord
