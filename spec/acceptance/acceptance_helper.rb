require File.expand_path("../../spec_helper.rb", __FILE__)

require 'steak'
require 'capybara/rails'

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Workaround for ActionDispatch::ClosedError
# https://github.com/binarylogic/authlogic/issues/262#issuecomment-1804988
User.acts_as_authentic_config[:maintain_sessions] = false

if ENV['HEADLESS'] == 'true'
  require 'headless'
  headless = Headless.new
  headless.start
  HEADLESS_DISPLAY = ":#{headless.display}"
  at_exit do
    headless.destroy
  end
  puts "Running in Headless mode. Display #{HEADLESS_DISPLAY}"
end

# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation, {:except => ['settings']}
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

RSpec.configuration.use_transactional_fixtures = false

RSpec.configuration.before(:each, :type => :acceptance) do
  DatabaseCleaner.clean
end

# Chrome browser
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

# Default timeout for extended for AJAX based application
Capybara.default_wait_time = 7
