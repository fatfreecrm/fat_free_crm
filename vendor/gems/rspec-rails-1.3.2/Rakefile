# -*- ruby -*-
gem 'hoe', '>=2.0.0'
require 'hoe'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__),"..","rspec","lib")))
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__),"lib")))

require 'spec/rails/version'
require 'spec/rake/spectask'
require 'cucumber/rake/task'

Hoe.spec 'rspec-rails' do
  self.version = Spec::Rails::VERSION::STRING
  self.summary = Spec::Rails::VERSION::SUMMARY
  self.description = "Behaviour Driven Development for Ruby on Rails."
  self.rubyforge_name = 'rspec'
  self.developer 'RSpec Development Team', 'rspec-devel@rubyforge.org'
  self.extra_deps = [["rspec",">=1.3.0"],["rack",">=1.0.0"]]
  self.extra_dev_deps = [["cucumber",">= 0.3.99"]]
  self.remote_rdoc_dir = "rspec-rails/#{Spec::Rails::VERSION::STRING}"
  self.history_file = 'History.rdoc'
  self.readme_file  = 'README.rdoc'
  self.post_install_message = <<-POST_INSTALL_MESSAGE
#{'*'*50}

  Thank you for installing rspec-rails-#{Spec::Rails::VERSION::STRING}
  
  If you are upgrading, do this in each of your rails apps
  that you want to upgrade:

    $ ruby script/generate rspec

  Please be sure to read History.rdoc and Upgrade.rdoc
  for useful information about this release.

#{'*'*50}
POST_INSTALL_MESSAGE
end

['audit','test','test_deps','default','post_blog', 'release'].each do |task|
  Rake.application.instance_variable_get('@tasks').delete(task)
end

task :post_blog do
  # no-op
end

task :release => [:clean, :package] do |t|
  version = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
  abort "Versions don't match #{version} vs #{Spec::Rails::VERSION::STRING}" unless version == Spec::Rails::VERSION::STRING
  pkg = "pkg/rspec-rails-#{version}"

  rubyforge = RubyForge.new.configure
  puts "Logging in to rubyforge ..."
  rubyforge.login

  puts "Releasing rspec-rails version #{version} ..."
  ["#{pkg}.gem", "#{pkg}.tgz"].each do |file|
    rubyforge.add_file('rspec', 'rspec', Spec::Rails::VERSION::STRING, file)
  end
end

Cucumber::Rake::Task.new

task :default => [:features]

namespace :update do
  desc "update the manifest"
  task :manifest do
    system %q[touch Manifest.txt; rake check_manifest | grep -v "(in " | patch]
  end
end
