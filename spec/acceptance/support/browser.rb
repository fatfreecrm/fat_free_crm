#
# Allow tests to run in Chrome browser
#
if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end

#
# Default timeout for extended for AJAX based application
#
Capybara.default_wait_time = 7
