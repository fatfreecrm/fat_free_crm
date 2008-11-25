require File.join(File.dirname(__FILE__), *%w[.. helper])

with_steps_for :running_rspec do
  run File.join(File.dirname(__FILE__), *%w[.. .. .. rspec stories configuration before_blocks.story]), :type => RailsStory
end