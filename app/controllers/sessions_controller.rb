class SessionsController < Devise::SessionsController
  respond_to :html
  append_view_path 'app/views/devise'

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
