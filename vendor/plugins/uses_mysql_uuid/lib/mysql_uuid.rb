module ActiveRecord
  module Uses
    module MySQL_UUID

      def self.included(base)
        base.extend(ClassMethods)
      end

      #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      module ClassMethods

        #--------------------------------------------------------------------------
        def uses_mysql_uuid
          unless already_uses_mysql_uuid?
            include ActiveRecord::Uses::MySQL_UUID::InstanceMethods
            extend ActiveRecord::Uses::MySQL_UUID::SingletonMethods
          end
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

    end
  end
end