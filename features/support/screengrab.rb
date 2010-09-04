############################## Screengrabs #############################
#
# sudo apt-get install xvfb ImageMagick OR yum install xorg-x11-server-Xvfb ImageMagick
# gem install headless
# Usage "HEADLESS=true cucumber features/"
#
# HEADLESS=true will run the cucumbers in xvfb rather than your browser window
# Files are saved in RAILS_ROOT/features/screengrabs/
#
# Add this step to take manual screengrabs:
#
# Then /^I take a screenshot called "(.*)"$/ do |image_name|
#  take_screengrab(image_name)
# end
#

module ScreenGrabHelper

  DEFAULT_SCREENGRAB_PATH = File.join(RAILS_ROOT, 'features', 'screengrabs')

  # credit http://monket.net/blog/2009/09/screenshots-of-failing-cucumber-scenarios/
  def take_screengrab_if_failed(scenario)
    if (scenario.status != :passed)
      scenario_name = scenario.to_sexp[3].gsub /[^\w\-]/, ' '
      time = Time.now.strftime("%Y-%m-%d %H%M")
      name = time + '-' + scenario_name + '-failed.png'
      puts "Taking a screengrab of failure: #{name}"
      take_screengrab(name)
    end
  end

  def take_screengrab(name)
    filename = File.join(DEFAULT_SCREENGRAB_PATH, name)
    ok_to_shoot = false
    if RUBY_PLATFORM =~ /mswin|mingw|bccwin|wince|em/
      # http://github.com/90kts/snapIt/blob/master/snapIt/bin/Release/snapIt.exe
      screengrab_cmd = "C:\\Tools\\SnapIt.exe"
      ok_to_shoot = File.exists?(screengrab_cmd)
      cmd = "#{screengrab_cmd} \"" + name + '"'
    else # RUBY_PLATFORM =~ /linux|darwin/
      screengrab_cmd = %x{which import}.strip
      display = defined?(HEADLESS_DISPLAY) ? HEADLESS_DISPLAY : ENV['DISPLAY']
      ok_to_shoot = !screengrab_cmd.blank? and !display.nil?
      cmd = "#{screengrab_cmd} -window root -display #{display} \"#{filename}\""
    end
    %x{#{cmd}} if ok_to_shoot
  end
  
end

World(ScreenGrabHelper)

if ENV['HEADLESS'] == 'true'
  require 'headless'
  headless = Headless.new
  headless.start
  HEADLESS_DISPLAY = ":#{headless.display}"
  at_exit do
    headless.destroy
  end
  puts "Running in Headless mode. Display #{HEADLESS_DISPLAY}" # TODO log.info
end

After('@javascript') do |scenario|
  take_screengrab_if_failed(scenario)
end

# Clean out the screengrab folder on each run
FileUtils.rm_rf(ScreenGrabHelper::DEFAULT_SCREENGRAB_PATH)
FileUtils.mkdir_p(ScreenGrabHelper::DEFAULT_SCREENGRAB_PATH)
