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


def skip_scenario?(scenario, file, name)
  # Skip the scenario if required by a loaded plugin.
  (file == File.basename(scenario.feature.file)) and (name.nil? || name == scenario.name)
end

# Plugins need to be able to inform the main cucumber suite when they have
# intentionally broken a scenario, so that the scenario can be skipped
# and overwritten safely.
Before do |scenario|
  FatFreeCRM::Cucumber.expected_failures.each do |plugin, file, name|  
    if skip_scenario?(scenario, file, name)
      print "/!" # Print at start of skipped steps
      scenario.instance_variable_get("@steps").each do |step|
        step.skip_invoke!
      end
    end  
  end 
end
After do |scenario|
  FatFreeCRM::Cucumber.expected_failures.each do |plugin, file, name|  
    print "(#{plugin.to_s})!/" if skip_scenario?(scenario, file, name) # Print at end of skipped steps
  end 
end

# Default timeout should be longer since this is an AJAX based application.
Capybara.default_wait_time = 7


# Add event.simulate.js to cucumber environment,
# so that we can simulate events such as mouseclicks.
class EventSimulateViewHooks < FatFreeCRM::Callback::Base
  def javascript_includes(view, context = {})
    view.javascript_include_tag "event.simulate.js"
  end
end

# Cancel any activity logging for Comment model (breaks cucumber tests)
Comment.class_eval do
  def log_activity; end
end

