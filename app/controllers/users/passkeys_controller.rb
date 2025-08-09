class Users::PasskeysController < DeviseController
  include Devise::Passkeys::Controllers::PasskeysControllerConcern

  def relying_party
    WebAuthn::RelyingParty.new(
      origin: "http://localhost:3000",
      name: "Fat Free CRM"
    )
  end
end
