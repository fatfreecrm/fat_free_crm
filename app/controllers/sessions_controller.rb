# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class SessionsController < Devise::SessionsController
  include Devise::Passkeys::Controllers::SessionsControllerConcern

  respond_to :html
  append_view_path 'app/views/devise'

  def relying_party
    WebAuthn::RelyingParty.new(
      origin: "http://localhost:3000",
      name: "Fat Free CRM"
    )
  end

  def after_sign_out_path_for(*)
    new_user_session_path
  end
end
