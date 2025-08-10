# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Devise::Passkeys::Controllers::SessionsControllerConcern

  def relying_party
    WebAuthn::RelyingParty.new(
      origin: "http://localhost:3000",
      name: "Fat Free CRM"
    )
  end
end
