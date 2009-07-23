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

module ActiveRecord
  module Uses
    module MySQL
      module UUID

        def self.included(base)
          base.extend(ClassMethods)
          if base.uuid_configured? && base.mysql5_or_later?
            puts "=> Enabling MySQL v5 UUID support"
          end
        end

        module ClassMethods

          def uses_mysql_uuid
            if uuid_configured? && mysql5_or_later? && !already_uses_mysql_uuid?
              include ActiveRecord::Uses::MySQL::UUID::InstanceMethods
              extend  ActiveRecord::Uses::MySQL::UUID::SingletonMethods
            end
          end

          # To enable the use of MySQL v5 UUID triggers config/database.yml should
          # have explicit "uuid: true" set.
          #--------------------------------------------------------------------------
          def uuid_configured?
            return false unless ActiveRecord::Base.connection
            config = ActiveRecord::Base.connection.instance_variable_get("@config")
            config[:uuid]
          end

          # CREATE TRIGGER ... BEFORE INSERT ... is only supported in MySQL 5+,
          # so for MySQL 4 or SQLite we don't hook into ActiveRecord.
          #--------------------------------------------------------------------------
          def mysql5_or_later?
            # First check whether the connection exists. This lets [rake db:create] run without complains.
            #
            # NOTE: return false unless ActiveRecord::Base.connected? doesn't appear to work with observed
            # models in Rails 2.2, so instead of checking connected? we test the connection itself.
            #
            return false unless ActiveRecord::Base.connection

            if ActiveRecord::Base.connection.adapter_name.downcase == "mysql"
              if ActiveRecord::Base.connection.select_value("SELECT VERSION()").to_i >= 5
                return true
              end
            end
            false
          end

          def already_uses_mysql_uuid?
            self.included_modules.include?(InstanceMethods)
          end

        end

        module InstanceMethods

          # Override default :id with :uuid for the model so it shows up in URLs.
          #--------------------------------------------------------------------------
          def to_param
            self.uuid
          end

          # Make sure we reload :uuid attribute that gets created by MySQL.
          #--------------------------------------------------------------------------
          def save(*args)
            success = super(*args)
            self.uuid = self.class.find(self.id, :select => :uuid).uuid if self.id && !self.uuid?
            success
          end

        end

        module SingletonMethods

          # Determine whether to call regular find() or find_by_uuid().
          #--------------------------------------------------------------------------
          def find(*args)
            if args.first =~ /\A[a-f\d\-]{36}\Z/
              send(:find_by_uuid, *args) || raise(RecordNotFound, "Couldn't find #{self.name} with ID=#{args.first}")
            else
              super(*args)
            end
          end
        end

      end # UUID
    end # MySQL
  end # Uses
end # ActiveRecord