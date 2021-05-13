# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Capaybara.app_host = ENV['APP_URL'] if ENV['APP_URL']
Capybara.default_max_wait_time = 7
Capybara.server = :webrick

if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: { args: %w[no-sandbox headless disable-gpu] })
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
  end
else
  # For local testing in an environment with a display or remote X server configured
  # such as WSL2, use NO_HEADLESS=1 bundle exec rspec spec/features
  #
  # For modern firefox, use MARIONETTE=1 bundle exec rspec spec/features
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.args << '--headless' unless ENV['NO_HEADLESS'].present?
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: ENV['MARIONETTE'].present?)
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options, desired_capabilities: capabilities)
  end
end
