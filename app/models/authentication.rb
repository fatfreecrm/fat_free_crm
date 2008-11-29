class Authentication < Authlogic::Session::Base # NOTE: This is not ActiveRecord model.
  self.configure do |config|
    config.authenticate_with = User
  end
  
  # All of the following code is for OpenID integration.
  attr_accessor :openid_identifier
  
  #----------------------------------------------------------------------------
  def authenticating_with_openid?
    !openid_identifier.blank? || controller.params[:open_id_complete]
  end
  
  #----------------------------------------------------------------------------
  def save(&block)
    if authenticating_with_openid?
      raise ArgumentError.new("You must supply a block to authenticate with OpenID") unless block_given?

      controller.send(:authenticate_with_open_id, openid_identifier) do |result, openid_identifier|
        if !result.successful?
          errors.add_to_base(result.message)
          yield false
          return
        end

        record = klass.find_by_openid_identifier(openid_identifier)

        if !record
          errors.add(:openid_identifier, "did not match any users in our database, have you set up your account to use OpenID?")
          yield false
          return
        end

        self.unauthorized_record = record
        super
      end
    else
      super
    end
  end

end
