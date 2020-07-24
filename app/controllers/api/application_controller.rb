module Api
  class ApplicationController < ActionController::Base
    before_action :require_api_user

    API_USER_ID = 2.freeze

    private

      def require_api_user
        api_key = get_bearer_token

        # the api key will be a hashed version of the string "username:encrypted_password" for the api user
        # check if that matches, and if so user is authentic
        api_user = User.find(API_USER_ID)
        key = Digest::SHA256.hexdigest("#{api_user.username}:#{api_user.encrypted_password}")

        unless key == api_key
          raise "Unknown user!"
        end
      end

      def get_bearer_token
        pattern = /^Bearer /
        header = request.authorization
        header.gsub(pattern, '') if header && header.match(pattern)
      end
  end
end
