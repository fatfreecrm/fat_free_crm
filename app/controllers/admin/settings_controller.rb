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
    settings = settings_params.to_h.with_indifferent_access

    # All settings are strings from the form.
    # We need to convert them to their correct types before saving.

    # Booleans
    %w[per_user_locale compound_address task_calendar_with_time require_first_names require_last_names require_unique_account_names comments_visible_on_dashboard enforce_international_phone_format].each do |key|
      settings[key] = (settings[key] == '1') if settings.key?(key)
    end

    # Nested booleans
    settings[:email_dropbox][:ssl] = (settings[:email_dropbox][:ssl] == '1') if settings.key?(:email_dropbox) && settings[:email_dropbox].key?(:ssl)
    settings[:email_comment_replies][:ssl] = (settings[:email_comment_replies][:ssl] == '1') if settings.key?(:email_comment_replies) && settings[:email_comment_replies].key?(:ssl)

    # Arrays from textareas
    %w[account_category campaign_status lead_status lead_source opportunity_stage task_category task_bucket task_completed priority_countries].each do |key|
      settings[key] = settings[key].split(/\r?\n/).map(&:strip).compact_blank if settings[key].is_a?(String)
    end

    # Symbols
    settings[:user_signup] = settings[:user_signup].to_sym if settings[:user_signup].is_a?(String)

    # Save all settings
    settings.each do |key, value|
      Setting[key] = value
    end

    redirect_to admin_settings_path, notice: t('fat_free_crm.settings_updated')
  end

  private

  def settings_params
    params.require(:settings).permit(
      :host, :base_url, :locale, :per_user_locale, :default_access, :user_signup,
      :compound_address, :task_calendar_with_time, :require_first_names,
      :require_last_names, :require_unique_account_names,
      :comments_visible_on_dashboard, :enforce_international_phone_format,
      :opportunity_default_stage,
      background_info: [],
      priority_countries: [],
      account_category: [],
      campaign_status: [],
      lead_status: [],
      lead_source: [],
      opportunity_stage: [],
      task_category: [],
      task_bucket: [],
      task_completed: [],
      smtp: %i[
        address from enable_starttls_auto port authentication
        user_name password
      ],
      email_dropbox: [
        :server, :port, :ssl, :address, :user, :password, :scan_folder,
        :attach_to_account, :move_to_folder, :move_invalid_to_folder,
        { address_aliases: [] }
      ],
      email_comment_replies: %i[
        server port ssl address user password scan_folder
        move_to_folder move_invalid_to_folder
      ],
      ai_prompts: %i[
        about_my_business how_i_plan_to_use_ffcrm
      ]
    )
  end

  def setup_current_tab
    set_current_tab('admin/settings')
  end
end
