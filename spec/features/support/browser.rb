# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
Capaybara.app_host = ENV['APP_URL'] if ENV['APP_URL']
Capybara.default_max_wait_time = 7
Capybara.server = :webrick

# For local testing in an environment with a display or remote X server configured
# such as WSL2, use NO_HEADLESS=1 bundle exec rspec spec/features
if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Options.chrome
    options.add_argument('--headless') unless ENV['NO_HEADLESS'].present?
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
else
  # NB the marionette setting is deprecated.
  # For modern firefox, sudo apt-get install firefox, geckodriver will be included.
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Options.firefox
    options.add_argument('-headless') unless ENV['NO_HEADLESS'].present?
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  end
end
