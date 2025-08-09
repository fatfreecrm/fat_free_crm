# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(FatFreeCRM::Application)
  FatFreeCRM::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb.

    # The test environment is used exclusively to run your application's
    # test suite.  You never need to work with it otherwise.  Remember that
    # your test database is "scratch space" for the test suite and is wiped
    # and recreated between test runs.  Don't rely on the data there!
    # Turn false under Spring and add config.action_view.cache_template_loading = true.
    config.cache_classes = true

    # Eager loading loads your whole application. When running a single test locally,
    # this probably isn't necessary. It's a good idea to do in a continuous integration
    # system, or in some way before deploying your code.
    config.eager_load = ENV["CI"].present?

    # Configure public file server for tests with Cache-Control for performance.
    config.public_file_server.enabled = true
    config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

    # Show full error reports and disable caching.
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false
    config.cache_store = :null_store

    # Raise exceptions instead of rendering exception templates.
    config.action_dispatch.show_exceptions = false

    # Disable request forgery protection in test environment.
    config.action_controller.allow_forgery_protection = false

    # Tell Action Mailer not to deliver emails to the real world.
    # The :test delivery method accumulates sent emails in the
    # ActionMailer::Base.deliveries array.
    config.action_mailer.delivery_method = :test

    # Set default host for mailer specs
    config.action_mailer.default_url_options = { host: "www.example.com" }

    # Randomize the order test cases are executed.
    config.active_support.test_order = :random

    # Print deprecation notices to the stderr.
    config.active_support.deprecation = :stderr

    # Store uploaded files on the local file system in a temporary directory
    config.active_storage.service = :test

    config.action_mailer.perform_caching = false
    # Raises error for missing translations
    # config.action_view.raise_on_missing_translations = true

    # Raises error for missing translations.
    # config.i18n.raise_on_missing_translations = true

    # Annotate rendered view with file names.
    # config.action_view.annotate_rendered_view_with_filenames = true
  end

  # Optionally load 'awesome_print' for debugging in development mode.
  begin
    require 'ruby-debug'
    require 'ap'
  rescue LoadError
  end
end
