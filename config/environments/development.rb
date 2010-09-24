# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

if File.exists?(File.join(RAILS_ROOT, 'tmp', 'debug.txt'))
  require 'ruby-debug'
  Debugger.wait_connection = true
  Debugger.start_remote
  File.delete(File.join(RAILS_ROOT, 'tmp', 'debug.txt'))
end

# Optionally load 'awesome_print' for debugging in development mode.
begin
  require 'ap'
rescue LoadError
end


# Add event.simulate.js to development environment,
# so that we can simulate events such as mouseclicks.
class DevelopmentViewHooks < FatFreeCRM::Callback::Base
  def javascript_includes(view, context = {})
    view.javascript_include_tag "event.simulate.js"
  end
end
