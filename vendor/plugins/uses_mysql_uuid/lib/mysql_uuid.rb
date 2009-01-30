module ActiveRecord
  module Uses
    module MySQL
      module UUID

        def self.included(base)
          base.extend(ClassMethods)
          puts "** UUID support is only available for MySQL v5 or later" if ActiveRecord::Base.connected? and !base.mysql5_or_later?
        end

        #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        module ClassMethods

          #--------------------------------------------------------------------------
          def uses_mysql_uuid
            if mysql5_or_later? && !already_uses_mysql_uuid?
              include ActiveRecord::Uses::MySQL::UUID::InstanceMethods
              extend ActiveRecord::Uses::MySQL::UUID::SingletonMethods
            end
          end

          # CREATE TRIGGER ... BEFORE INSERT ... is only supported in MySQL 5+,
          # so for MySQL 4 or SQLite we don't hook into ActiveRecord.
          #--------------------------------------------------------------------------
          def mysql5_or_later?
            # First check whether the connection exists. This lets [rake db:create] run without complains.
            return false unless ActiveRecord::Base.connected?

            if ActiveRecord::Base.connection.adapter_name.downcase == "mysql"
              if ActiveRecord::Base.connection.select_value("SELECT VERSION()").to_i >= 5
                return true
              end
            end
            false
          end

          #--------------------------------------------------------------------------
          def already_uses_mysql_uuid?
            self.included_modules.include?(InstanceMethods)
          end

        end

        #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
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

        #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        module SingletonMethods

          # Determine whether to call regular find() or find_by_uuid().
          #--------------------------------------------------------------------------
          def find(*args)
            if args.first =~ /\A[a-f\d\-]{36}\Z/
              send(:find_by_uuid, *args)
            else
              super(*args)
            end
          end
        end

      end # UUID
    end # MySQL
  end # Uses
end # ActiveRecord