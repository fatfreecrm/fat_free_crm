require 'bundler'
Bundler.setup

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "devise_facebook_open_graph #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


task :gem do
  system %(rm -f *.gem; gem build is_paranoid.gemspec)
end
