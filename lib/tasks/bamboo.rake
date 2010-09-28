unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks

  begin # only install task if Cucumber is available

    require 'cucumber/rake/task'
 
    namespace :bamboo do
      desc 'Run the cucumbers for bamboo. Use HEADLESS=true if you want to run in xvfb'
      Cucumber::Rake::Task.new(:cucumber) do |t|
        t.rcov = true
        t.cucumber_opts = ["--format junit --out 'features/reports'"]
      end
    end

  rescue LoadError
    desc 'cucumber rake task not available (cucumber not installed)'
    task :cucumber do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
  end
end

begin
  namespace :bamboo do
    desc 'Run the specs for bamboo (requires ci_reporter)'   
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.spec_opts = ["--require ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec"]
      t.pattern   = 'spec/**/*_spec.rb'
    end
  end
rescue
  puts "RSpec not installed."  
end
