class RegistrationsController < Devise::RegistrationsController
  respond_to :html
  append_view_path 'app/views/devise'

  def edit
    redirect_to profile_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
