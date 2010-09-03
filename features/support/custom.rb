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
  at_exit do
    headless.destroy
  end
  puts "Running in Headless mode"
end
  
Spork.prefork do
  require "factory_girl"
  require RAILS_ROOT + "/spec/factories"
end

Spork.each_run do
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

