# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Capaybara.app_host = ENV['APP_URL'] if ENV['APP_URL']
Capybara.default_max_wait_time = 7
Capybara.server = :webrick

if ENV['BROWSER'] == 'firefox'
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.args << '--headless'
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false)
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options, desired_capabilities: capabilities)
  end
else
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("headless")
    options.add_argument("--window-size=1024,768")

    if RUBY_PLATFORM =~ /darwin/
      options.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
    end

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.open_timeout = 120 # instead of the default 60
    client.read_timeout = 120 # instead of the default 60

    Capybara::Selenium::Driver.new(app,
      browser: :chrome,
      options: options,
      http_client: client
    )
  end
end
