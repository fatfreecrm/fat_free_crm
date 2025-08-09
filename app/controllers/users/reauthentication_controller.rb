class Users::ReauthenticationController < DeviseController
  include Devise::Passkeys::Controllers::ReauthenticationControllerConcern

  def relying_party
    WebAuthn::RelyingParty.new(
      origin: "http://localhost:3000",
      name: "Fat Free CRM"
    )
  end
end
