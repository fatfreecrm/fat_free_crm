# Rack Dispatcher

# Require your environment file to bootstrap Rails
# NOTE: use ::File.dirname instead of File.dirname for Ruby 1.9.1 compatibility.
require ::File.dirname(__FILE__) + '/config/environment'

# See http://www.themomorohoax.com/2009/11/22/how-to-fix-issue-where-heroku-doesnt-serve-css-images-and-static-files
# and http://guides.rubyonrails.org/rails_on_rack.html
use Rails::Rack::LogTailer
use Rails::Rack::Static

# Dispatch the request
run ActionController::Dispatcher.new
