require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

begin
  AUTHOR   = "Michael Deering"
  EMAIL    = "mdeering@mdeering.com"
  GEM      = "gravatar_image_tag"
  HOMEPAGE = "http://github.com/mdeering/gravatar_image_tag"
  SUMMARY  = "A configurable and documented Rails view helper for adding gravatars into your Rails application."

  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.author       = AUTHOR
    s.email        = EMAIL
    s.files        = %w(install.rb install.txt MIT-LICENSE README.textile Rakefile) + Dir.glob("{rails,lib,spec}/**/*")
    s.homepage     = HOMEPAGE
    s.name         = GEM
    s.require_path = 'lib'
    s.summary      = SUMMARY
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end

desc 'Default: spec tests.'
task :default => :spec

desc 'Test the gravatar_image_tag gem.'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ["-c"]
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', '/opt,spec,Library']
end

desc 'Generate documentation for the gravatar_image_tag plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GravatarImageTag'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
