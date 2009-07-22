# Rack Dispatcher

# Require your environment file to bootstrap Rails
# NOTE: use ::File.dirname instead of File.dirname for Ruby 1.9.1 compatibility.
require ::File.dirname(__FILE__) + '/config/environment'

# Dispatch the request
run ActionController::Dispatcher.new
