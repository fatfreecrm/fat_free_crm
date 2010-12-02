module AuthlogicApi
  # Handles configuration for the _api_key_ and _api_secret_ fields of your ApplicationAccount model.
  #
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        extend Config
        add_acts_as_authentic_module(Methods)
      end
    end
    
    module Config
      # The name of the api key field in the database.
      #
      # * <tt>Default:</tt> :api_key or  :application_key, if they exist
      # * <tt>Accepts:</tt> Symbol
      def api_key_field(value = nil)
        rw_config(:api_key_field, value, first_column_to_exist(nil, :api_key, :application_key))
      end
      alias_method :api_key_field=, :api_key_field

      # The name of the api secret field in the database.
      #
      # * <tt>Default:</tt> :api_secret or  :application_secret, if they exist
      # * <tt>Accepts:</tt> Symbol
      def api_secret_field(value = nil)
        rw_config(:api_secret_field, value, first_column_to_exist(nil, :api_secret, :application_secret))
      end
      alias_method :api_secret_field=, :api_secret_field

      # Switch to control wether the _api_key_ and _api_secret_ fields should be automatically generated for you.
      # Note that the generation is done in a before_validation callback, and if you already populated these fields they
      # will not be overridden.
      #
      # * <tt>Default:</tt> true
      # * <tt>Accepts:</tt> Boolean
      def enable_api_fields_generation(value = nil)
        rw_config(:enable_api_fields_generation, value, true)
      end
      alias_method :enable_api_fields_generation=, :enable_api_fields_generation

    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          before_validation :generate_key_and_secret, :if => :enable_api_fields_generation?
        end
      end
    
      private
    
      def has_api_columns?
        self.class.api_key_field && self.class.api_secret_field
      end
    
      def enable_api_fields_generation?
        self.class.enable_api_fields_generation && has_api_columns?
      end
    
      def generate_key_and_secret
        send("#{self.class.api_key_field}=", Authlogic::Random.friendly_token) unless send(self.class.api_key_field)
        send("#{self.class.api_secret_field}=", Authlogic::Random.hex_token) unless send(self.class.api_secret_field)
      end
    end
  
  end
end
