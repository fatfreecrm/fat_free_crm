# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(FatFreeCRM::Application)
  FatFreeCRM::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb
    config.eager_load = false

    # In the development environment your application's code is reloaded on
    # every request. This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    config.assets.quiet = true

    # Show full error reports and disable caching
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    config.action_mailer.delivery_method = :file

    # Don't care if the mailer can't send
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger
    config.active_support.deprecation = :log

    # Only use best-standards-support built into browsers
    # config.action_dispatch.best_standards_support = :builtin

    # Raise an error on page load if there are pending migrations
    config.active_record.migration_error = :page_load

    # Expands the lines which load the assets
    config.assets.debug = true

    # Asset digests allow you to set far-future HTTP expiration dates on all assets,
    # yet still be able to expire them through the digest params.
    config.assets.digest = true

    # Adds additional error checking when serving assets at runtime.
    # Checks for improperly declared sprockets dependencies.
    # Raises helpful error messages.
    config.assets.raise_runtime_errors = true
  end
end
