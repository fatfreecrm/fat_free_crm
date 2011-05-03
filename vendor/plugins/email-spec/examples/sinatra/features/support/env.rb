# Sinatra configuration - http://wiki.github.com/aslakhellesoy/cucumber/sinatra
ENV["RAILS_ENV"] ||= "cucumber"
app_file = File.expand_path(File.dirname(__FILE__) + '/../../app.rb')
require app_file
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file

require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'cucumber/web/tableish'

require 'spec/expectations'
require 'rack/test'
require 'test/unit'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rack
  config.open_error_files = false # Set to true if you want error pages to pop up in the browser
end

# email testing in cucumber
require 'activesupport'
require File.expand_path(File.dirname(__FILE__) + '../../../../../lib/email_spec')
require 'email_spec/cucumber'

class AppWorld
  include Rack::Test::Methods
  include Test::Unit::Assertions
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application.new
  end
end

World { AppWorld.new }
