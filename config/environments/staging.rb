# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(FatFreeCRM::Application)
  FatFreeCRM::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb
    config.eager_load = true

    # Code is not reloaded between requests
    config.cache_classes = true

    # Full error reports are enabled, since this is an internal application.
    config.consider_all_requests_local       = false
    # Caching is turned on
    config.action_controller.perform_caching = true

    # Disable Rails's static asset server (Apache or nginx will already do this)
    config.serve_static_files = true

    # Compress JavaScripts and CSS
    config.assets.compress = true

    # Don't fallback to assets pipeline if a precompiled asset is missed
    config.assets.compile = false

    # Generate digests for assets URLs
    config.assets.digest = true

    # Defaults to Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # Specifies the header that your server uses for sending files
    # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
    # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    # config.force_ssl = true

    # See everything in the log (default is :info)
    # config.log_level = :debug

    # Use a different logger for distributed setups
    # config.logger = SyslogLogger.new

    # Use a different cache store in production
    # config.cache_store = :mem_cache_store

    # Enable serving of images, stylesheets, and JavaScripts from an asset server
    # config.action_controller.asset_host = "http://assets.example.com"

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    # config.assets.precompile += %w( search.js )

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    # Send deprecation notices to registered listeners
    config.active_support.deprecation = :notify

    # Do not dump schema after migrations.
    config.active_record.dump_schema_after_migration = false
  end
end
