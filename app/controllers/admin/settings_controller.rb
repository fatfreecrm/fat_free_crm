# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::SettingsController < Admin::ApplicationController
  before_action :setup_current_tab, only: [:index]

  # GET /admin/settings
  # GET /admin/settings.xml
  #----------------------------------------------------------------------------
  def index
  end

  # PUT /admin/settings
  #----------------------------------------------------------------------------
  def update
    Setting[:about_my_business] = params[:settings][:about_my_business]
    Setting[:how_i_plan_to_use_ffcrm] = params[:settings][:how_i_plan_to_use_ffcrm]

    redirect_to admin_settings_path
  end

  private

  def settings_params
    params.require(:settings).permit(:about_my_business, :how_i_plan_to_use_ffcrm)
  end

  def setup_current_tab
    set_current_tab('admin/settings')
  end
end
