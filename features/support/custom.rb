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

# Add event.simulate.js to cucumber environment,
# so that we can simulate events such as mouseclicks.
class EventSimulateViewHooks < FatFreeCRM::Callback::Base

  def javascript_includes(view, context = {})
    view.javascript_include_tag "event.simulate.js"
  end

end

# Cancel any activity logging for Comment model
Comment.class_eval do
  def log_activity; end
end
