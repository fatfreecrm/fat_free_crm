FatFreeCRM::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  if File.exists?(File.join(Rails.root, 'tmp', 'debug.txt'))
    require 'ruby-debug'
    Debugger.wait_connection = true
    Debugger.start_remote
    File.delete(File.join(Rails.root, 'tmp', 'debug.txt'))
  end

  # ActionMailer needs to be loaded here so that we can set default_url_options in the controller.
  ActionMailer::Base
end

ActiveSupport.on_load(:after_initialize) do
  ActionController::Base.before_filter do
    ActionController::Base.view_paths.each(&:clear_cache)
  end
end


# Optionally load 'ruby-debug' and 'awesome_print' for debugging in development mode.
begin
  require 'ruby-debug'
  require 'ap'
rescue LoadError
end

