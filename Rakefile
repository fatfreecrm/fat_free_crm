# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

desc 'Run the specs for bamboo (requires ci_reporter)'
Spec::Rake::SpecTask.new(:bamboo) do |t|
  t.spec_opts = ["--require #{Gem.path.last}/gems/ci_reporter-1.6.2/lib/ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

