module ActiveRecord
  module Uses
    module User
      module Permissions

        def self.included(base)
          base.extend(ClassMethods)
        end

        #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        module ClassMethods

          #--------------------------------------------------------------------------
          def uses_user_permissions
            unless already_uses_user_permissions?
              has_many :permissions, :as => :asset, :include => :user
              include ActiveRecord::Uses::User::Permissions::InstanceMethods
              extend  ActiveRecord::Uses::User::Permissions::SingletonMethods
            end
          end

          #--------------------------------------------------------------------------
          def already_uses_user_permissions?
            self.included_modules.include?(InstanceMethods)
          end

        end

        #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        module InstanceMethods

          # Save the account along with its permissions if any.
          #--------------------------------------------------------------------------
          def save_with_permissions(users)
            if users && self[:access] == "Shared"
              users.each { |id| self.permissions << Permission.new(:user_id => id, :asset => self) }
            end
            save
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

        #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        module SingletonMethods
        end

      end # Permissions
    end # User
  end # Uses
end # ActiveRecord
