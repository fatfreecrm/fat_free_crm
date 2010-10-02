require "factory_girl"
require "#{::Rails.root}/spec/factories"

#
# headless
# sudo apt-get install xvfb
# OR yum install xorg-x11-server-Xvfb.x86_64
# gem install headless
#
if ENV['HEADLESS'] == 'true'
  require 'headless'
  headless = Headless.new
  headless.start
  HEADLESS_DISPLAY = headless.display
  at_exit do
    headless.destroy
  end
  puts "Running in Headless mode. Display #{HEADLESS_DISPLAY}"
end

# Require plugin.rb support files from each plugin.
Dir.glob("#{Rails.root}/vendor/plugins/**/support/plugin.rb").each {|f| require f }

# Default timeout should be longer since this is an AJAX based application.
Capybara.default_wait_time = 7

# Cancel any activity logging for Comment model (breaks cucumber tests)
Comment.class_eval do
  def log_activity; end
end

