# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
if defined?(FatFreeCRM::Application)
  FatFreeCRM::Application.configure do
    # The test environment is used exclusively to run your application's
    # test suite.  You never need to work with it otherwise.  Remember that
    # your test database is "scratch space" for the test suite and is wiped
    # and recreated between test runs.  Don't rely on the data there!
    config.cache_classes = true

    # Do not eager load code on boot. This avoids loading your whole application
    # just for the purpose of running a single test. If you are using a tool that
    # preloads Rails for running tests, you may have to set it to true.
    config.eager_load = false

    # Configure static file server for tests with Cache-Control for performance.
    config.public_file_server.enabled = true
    config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

    # Show full error reports and disable caching
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Raise exceptions instead of rendering exception templates
    config.action_dispatch.show_exceptions = false

    # Disable request forgery protection in test environment
    config.action_controller.allow_forgery_protection = false

    # Tell Action Mailer not to deliver emails to the real world.
    # The :test delivery method accumulates sent emails in the
    # ActionMailer::Base.deliveries array.
    config.action_mailer.delivery_method = :test

    # Set default host for mailer specs
    config.action_mailer.default_url_options = { host: "www.example.com" }

    # Randomize the order test cases are executed.
    config.active_support.test_order = :random

    # Print deprecation notices to the stderr
    config.active_support.deprecation = :stderr
  end

  # Optionally load 'awesome_print' for debugging in development mode.
  begin
    require 'ruby-debug'
    require 'ap'
  rescue LoadError
  end
end
