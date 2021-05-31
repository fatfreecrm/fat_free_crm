# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::ApplicationController < ApplicationController
  before_action :require_admin_user

  layout "admin/application"
  helper "admin/field_groups"

  # Autocomplete handler for all admin controllers.
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:term]
    @auto_complete = klass.text_search(@query).limit(10)
    render partial: 'auto_complete'
  end

  private

  #----------------------------------------------------------------------------
  def require_admin_user
    authenticate_user!
    unless current_user&.admin?
      flash[:notice] = t(:msg_require_admin)
      redirect_to root_path
    end
  end
end
