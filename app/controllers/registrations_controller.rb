class RegistrationsController < Devise::RegistrationsController
  respond_to :html
  append_view_path 'app/views/devise'

  def after_inactive_sign_up_path_for(resource)
    "/login"
  end
end
