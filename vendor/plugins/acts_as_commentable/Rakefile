require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "acts_as_commentable"
NAME = "acts_as_commentable"
GEM_VERSION = "1.0.0"
AUTHOR = "Cosmin Radoi"
EMAIL = "unknown@juixe.com"
HOMEPAGE = "http://www.juixe.com/techknow/index.php/2006/06/18/acts-as-commentable-plugin/"
SUMMARY = "Plugin/gem that provides comment functionality"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb', '>= 0.5.0')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(MIT-LICENSE README Rakefile) + Dir.glob("{lib,specs}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{GEM_VERSION}}
end