Spork.prefork do
  require "factory_girl"
  require RAILS_ROOT + "/spec/factories"

  require "selenium-webdriver"
  Selenium::WebDriver.for :chrome
end

Spork.each_run do
end
