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
    if Setting.update(settings_params)
      flash[:notice] = t(:msg_asset_updated, "Settings")
      redirect_to admin_settings_path
    else
      render :index
    end
  end

  private

  def settings_params
    params.require(:settings).permit!
  end

  def setup_current_tab
    set_current_tab('admin/settings')
  end
end
