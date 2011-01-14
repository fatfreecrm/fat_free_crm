module AuthlogicApi
  # Note that because authenticating through an API is a single access authentication, many of the magic columns are
  # not updated. Here is a list of the magic columns with their update state:
  #   login_count           Never increased because there's no explicit login
  #   failed_login_count    Updated. That is every signature mismatch will increase this value.
  #   last_request_at       Updated.
  #   current_login_at      Left unchanged.
  #   last_login_at         Left unchanged.
  #   current_login_ip      Left unchanged.
  #   last_login_ip         Left unchanged.
  #
  # AuthlogicApi adds some more magic columns to fill the gap, here they are:
  #   request_count         Increased every time a request is made.
  #                         Counts also invalid requests, so this is the total count.
  #                         To have the count of valid requests use : request_count - failed_login_count
  #   last_request_ip       Updates with the request remote_ip for each request.
  #
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end
    
    module Config
      # Defines the param key name where the api_key will be received.
      #
      # You *must* define this to enable API authentication.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> String
      def api_key_param(value = nil)
        rw_config(:api_key_param, value, nil)
      end
      alias_method :api_key_param=, :api_key_param

      # Defines the param key name where the signature will be received.
      #
      # * <tt>Default:</tt> 'signature'
      # * <tt>Accepts:</tt> String
      def api_signature_param(value = nil)
        rw_config(:api_signature_param, value, 'signature')
      end
      alias_method :api_signature_param=, :api_signature_param
      
      # To be able to authenticate the incoming request, AuthlogicApi has to find a valid api_key in your system.
      # This config setting let's you choose which method to call on your model to get an application model object.
      #
      # Let's say you have an ApplicationSession that is authenticating an ApplicationAccount. By default ApplicationSession will
      # call ApplicationAccount.find_by_api_key(api_key).
      #
      # * <tt>Default:</tt> :find_by_api_key
      # * <tt>Accepts:</tt> Symbol or String
      def find_by_api_key_method(value = nil)
        rw_config(:find_by_api_key_method, value, :find_by_api_key)
      end
      alias_method :find_by_api_key_method=, :find_by_api_key_method

      # The generation of the request signature is selectable by this config setting.
      # You may either directly override the Methods#generate_api_signature method on the Session class,
      # or use this config to select another method.
      #
      # The default implementation of #generate_api_signature is the following:
      #   def generate_api_signature(secret)
      #     Digest::MD5.hexdigest(build_api_payload + secret)
      #   end
      #
      # Note the call to #build_api_payload, which is another method you may override to customize
      # your own way of building the payload that will be signed.
      # WARNING: The current implementation of #build_api_payload is Rails oriented. Override if you use another framework.
      #
      # * <tt>Default:</tt> :generate_api_signature
      # * <tt>Accepts:</tt> Symbol
      def generate_api_signature_method(value = nil)
        rw_config(:generate_api_signature_method, value, :generate_api_signature)
      end
      alias_method :generate_api_signature_method=, :generate_api_signature_method
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          attr_accessor :single_access
          persist :persist_by_api, :if => :authenticating_with_api?
          validate :validate_by_api, :if => :authenticating_with_api?
          after_persisting :set_api_magic_columns, :if => :authenticating_with_api?
        end
      end
      
      # Hooks into credentials to print out meaningful credentials for API authentication.
      def credentials
        authenticating_with_api? ? {:api_key => api_key} : super
      end
      
      private
        def persist_by_api
          self.unauthorized_record = search_for_record(self.class.find_by_api_key_method, api_key)
          self.single_access = valid?
        end

        def validate_by_api
          self.attempted_record = search_for_record(self.class.find_by_api_key_method, api_key)
          if attempted_record.blank?
            generalize_credentials_error_messages? ?
              add_general_credentials_error :
              errors.add(api_key_param, I18n.t('error_messages.api_key_not_found', :default => "is not valid"))
            return
          end
        
          signature = send(self.class.generate_api_signature_method, attempted_record.send(klass.api_secret_field))
          if api_signature != signature
            self.invalid_password = true  # magic columns housekeeping
            generalize_credentials_error_messages? ?
              add_general_credentials_error :
              errors.add(api_signature_param, I18n.t('error_messages.invalid_signature', :default => "is not valid"))
            return
          end
        end

        def authenticating_with_api?
          !api_key.blank? && !api_signature.blank?
        end
      
        def api_key
          controller.params[api_key_param]
        end

        def api_signature
          controller.params[api_signature_param]
        end
      
        def api_key_param
          self.class.api_key_param
        end
      
        def api_signature_param
          self.class.api_signature_param
        end

        # WARNING: Rails specfic way of building payload
        def build_api_payload
          request = controller.request
          if (request.post? || request.put?) && request.raw_post.present?
            request.raw_post
          else
            params = request.query_parameters.reject {|key, value| key.to_s == api_signature_param}
            params.sort_by {|key, value| key.to_s.underscore}.join('')
          end
        end
      
        def generate_api_signature(secret)
          Digest::MD5.hexdigest(build_api_payload + secret)
        end
      
        def set_api_magic_columns
          record.request_count = (record.request_count.blank? ? 1 : record.request_count + 1) if record.respond_to?(:request_count)
          record.last_request_ip = controller.request.remote_ip if record.respond_to?(:last_request_ip)
        end

    end
  end
end
