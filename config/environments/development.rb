# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(FatFreeCRM::Application)
  FatFreeCRM::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb.

    # In the development environment your application's code is reloaded any time
    # it changes. This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    # Do not eager load code on boot.
    config.eager_load = false

    # Show full error reports.
    config.consider_all_requests_local = true

    # Enable server timing
    config.server_timing = true

    # Enable/disable caching. By default caching is disabled.
    # Run rails dev:cache to toggle caching.
    if Rails.root.join("tmp/caching-dev.txt").exist?
      config.action_controller.perform_caching = true
      config.action_controller.enable_fragment_cache_logging = true

      config.cache_store = :memory_store
      config.public_file_server.headers = {
        "Cache-Control" => "public, max-age=#{2.days.to_i}"
      }
    else
      config.action_controller.perform_caching = false

      config.cache_store = :null_store
    end

    # Store uploaded files on the local file system (see config/storage.yml for options).
    config.active_storage.service = :local

    config.action_mailer.delivery_method = :file
    config.action_mailer.default_url_options = { host: 'localhost:3000' }

    # Don't care if the mailer can't send.
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger.
    config.active_support.deprecation = :log

    # Only use best-standards-support built into browsers
    # config.action_dispatch.best_standards_support = :builtin

    # Raise an error on page load if there are pending migrations.
    config.active_record.migration_error = :page_load

    # Highlight code that triggered database queries in logs.
    config.active_record.verbose_query_logs = true

    # Expands the lines which load the assets
    config.assets.debug = true

    # Asset digests allow you to set far-future HTTP expiration dates on all assets,
    # yet still be able to expire them through the digest params.
    config.assets.digest = true

    # Suppress logger output for asset requests.
    config.assets.quiet = true

    # Raises error for missing translations.
    # config.i18n.raise_on_missing_translations = true

    # Annotate rendered view with file names.
    # config.action_view.annotate_rendered_view_with_filenames = true

    # Uncomment if you wish to allow Action Cable access from any origin.
    # config.action_cable.disable_request_forgery_protection = true

    # Adds additional error checking when serving assets at runtime.
    # Checks for improperly declared sprockets dependencies.
    # Raises helpful error messages.
    config.assets.raise_runtime_errors = true
  end
end
