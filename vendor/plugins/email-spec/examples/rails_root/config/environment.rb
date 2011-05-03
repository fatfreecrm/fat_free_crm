# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.action_mailer.default_url_options = { :host => "example.com" }

  config.gem 'fixjour',     :lib => 'fixjour'
  config.gem 'delayed_job', :lib => 'delayed_job'
  config.gem 'mimetype-fu', :lib => 'mimetype_fu'

  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_es_session',
    :secret      => 'b9327c7967925fb36f8901e43f47e0a3e8fc7856ae1b4533ddeda776381548f9ac051721446fdbc4ccc88c7353124708e73d8b0950a30487571d8f8eb5b24732'
  }

end
