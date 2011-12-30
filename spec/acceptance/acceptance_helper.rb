require File.expand_path("../spec_helper.rb", __FILE__)

require 'steak'
require 'capybara/rails'

module Steak::Capybara
  include Rack::Test::Methods
  include Capybara

  def app
    ::Rails.application
  end
end

RSpec.configuration.include Steak::Capybara, :type => :acceptance

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

# Default timeout for extended for AJAX based application
Capybara.default_wait_time = 7
