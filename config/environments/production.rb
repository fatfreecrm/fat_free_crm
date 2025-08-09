# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(FatFreeCRM::Application)
  FatFreeCRM::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb.

    # Code is not reloaded between requests.
    config.cache_classes = true

    # Eager load code on boot. This eager loads most of Rails and
    # your application in memory, allowing both threaded web servers
    # and those relying on copy on write to perform better.
    # Rake tasks automatically ignore this option for performance.
    config.eager_load = true

    # Full error reports are disabled and caching is turned on.
    config.consider_all_requests_local       = false
    config.action_controller.perform_caching = true

    # Disable Rails's static asset server (Apache or nginx will already do this)
    config.public_file_server.enabled = true

    # Compress JavaScripts and CSS
    config.assets.compress = true

    # Do not fallback to assets pipeline if a precompiled asset is missed.
    config.assets.compile = false

    # Generate digests for assets URLs
    config.assets.digest = true

    # Specifies the header that your server uses for sending files.
    # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
    # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    # config.force_ssl = true

    # Include generic and useful information about system operation, but avoid logging too much
    # information to avoid inadvertent exposure of personally identifiable information (PII).
    config.log_level = :info

    # Use a different logger for distributed setups
    # config.logger = SyslogLogger.new

    # Use a different cache store in production.
    # config.cache_store = :mem_cache_store

    # Enable serving of images, stylesheets, and JavaScripts from an asset server
    # config.action_controller.asset_host = "http://assets.example.com"

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    # config.assets.precompile += %w( search.js )

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation cannot be found).
    config.i18n.fallbacks = true

    # Send deprecation notices to registered listeners
    config.active_support.deprecation = :notify

    # Do not dump schema after migrations.
    config.active_record.dump_schema_after_migration = false
  end
end
