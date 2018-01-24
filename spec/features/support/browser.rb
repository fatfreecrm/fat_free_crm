# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Capaybara.app_host = ENV['APP_URL'] if ENV['APP_URL']
Capybara.default_max_wait_time = 7

if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: { args: ['no-sandbox', 'headless', 'disable-gpu'] })
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
  end
else
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.args << '--headless'
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false)
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options, desired_capabilities: capabilities)
  end
end
