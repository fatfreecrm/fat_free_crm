require 'rubygems'
require 'spec/rake/spectask'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name         = "email_spec"
    s.platform     = Gem::Platform::RUBY
    s.authors      = ['Ben Mabey', 'Aaron Gibralter', 'Mischa Fierer']
    s.email        = "ben@benmabey.com"
    s.homepage     = "http://github.com/bmabey/email-spec/"
    s.summary      = "Easily test email in rspec and cucumber"
    s.bindir       = "bin"
    s.description  = s.summary
    s.require_path = "lib"
    s.files        = %w(History.txt install.rb MIT-LICENSE.txt README.rdoc Rakefile) + Dir["lib/**/*"] + Dir["rails_generators/**/*"]
    s.test_files   = Dir["spec/**/*"] + Dir["examples/**/*"]
    # rdoc
    s.has_rdoc         = true
    s.extra_rdoc_files = %w(README.rdoc MIT-LICENSE.txt)
    s.rubyforge_project = 'email-spec'
    s.add_dependency 'rspec'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

# TODO: switch to gem bundler
([['delayed_job', '2.0.3']] + %w[mimetype-fu fixjour pony sinatra rack-test].map{|g| [g]}).each do |gem_args|
  gem_name = gem_args.first
  gem_version = gem_args.size > 1 ? gem_args[1] : nil
  begin
    gem(*[gem_args].flatten)
  rescue Gem::LoadError
    puts "Installing #{gem_name} for the example rails app..."
    puts `gem install #{gem_name} #{gem_version ? ('--version='+gem_version) : ''} --no-rdoc --no-ri`
  end
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :example_app do
  Spec::Rake::SpecTask.new(:spec) do |spec|
    desc "Specs for Example app"
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['examples/rails_root/spec/**/*_spec.rb']
  end
end

task :default => [:features, :spec, 'example_app:spec']

desc "Cleans the project of any tmp file that should not be included in the gemspec."
task :clean do
  FileUtils.rm_f('examples/rails_root/features/step_definitions/email_steps.rb')
  FileUtils.rm_rf('examples/rails_root/log')
  FileUtils.rm_rf('examples/rails_root/vendor')
  %w[*.sqlite3 *.log].each do |pattern|
    `find . -name "#{pattern}" -delete`
  end
end

desc "Cleans the dir and builds the gem"
task :prep => [:clean, :gemspec, :build]

