# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include Devise::Passkeys::Controllers::RegistrationsControllerConcern
end
