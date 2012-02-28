module Authlogic
  module Cas
    module SingleSignOut
      class Cache

        class << self
        
          def logger
            @logger ||= Rails.logger
          end
          
          def delete_service_ticket(service_ticket)
            logger.info("Deleting index #{service_ticket}")
            Rails.cache.delete(cache_key(service_ticket))
          end
          
          def find_unique_cas_id_by_service_ticket(session_index)
            ido_id = Rails.cache.read(cache_key(session_index))
            logger.debug("Found session id #{ido_id.inspect} for index #{session_index.inspect}")
            ido_id
          end
          
          def store_unique_cas_id_for_service_ticket(session_index, ido_id)
            Rails.cache.write(cache_key(session_index), ido_id)
          end
          
          private
          
          def cache_key(session_index)
            "authlogic_cas:#{session_index}"
          end

        end
      end
    end
  end
end

