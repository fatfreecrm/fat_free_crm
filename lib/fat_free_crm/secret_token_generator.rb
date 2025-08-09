# frozen_string_literal: true

# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'securerandom'

module FatFreeCRM
  class SecretTokenGenerator
    class << self
      #
      # If there is no secret token defined, we generate one and save it as a setting
      # If a token has been already been saved, we tell Rails to use it and move on.
      def setup!
        unless token_exists?
          Rails.logger.info("No secret key defined yet... generating and saving to Setting.secret_token")
          new_token!
        end
        # If db isn't setup yet, token will return nil, provide a randomly generated one for now.
        FatFreeCRM::Application.config.secret_key_base = (token || generate_token)
      end

      private

      def token_exists?
        Setting.secret_token.present?
      end

      #
      # Read the current token from settings
      def token
        Setting.secret_token
      end

      #
      # Create a new secret token and save it as a setting.
      def new_token!
        quietly do
          Setting.secret_token = generate_token
        end
      end

      def generate_token
        SecureRandom.hex(64)
      end

      #
      # Yields to a block that executes with the logging turned off
      # This stops the secret token from being appended to the log
      def quietly(&_block)
        temp_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
        yield
        ActiveRecord::Base.logger = temp_logger
      end
    end
  end
end
