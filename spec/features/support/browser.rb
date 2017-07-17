# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
#
# Allow tests to run in Chrome browser
#
if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end
else
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :firefox, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false))
  end
end

#
# Default timeout for extended for AJAX based application
#
Capybara.default_max_wait_time = 7
