# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class PasswordsController < Devise::PasswordsController

  respond_to :html
  append_view_path 'app/views/devise'

  #----------------------------------------------------------------------------
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if resource.errors.empty?
      flash[:notice] = t(:msg_pwd_instructions_sent)
      redirect_to root_url
    else
      # Redirect to custom page instead of displaying errors
      # redirect_to my_custom_page_path
      Rails.logger.info(resource.errors.inspect)
      flash[:notice] = t(:msg_email_not_found)
      redirect_to root_url
    end
  end

  #----------------------------------------------------------------------------
  def edit
    # <-- render edit.html.haml
  end

  #----------------------------------------------------------------------------
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end
end
