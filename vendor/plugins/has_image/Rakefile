require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

task :all_tests  => [:test, :test_rails]

desc 'Test the non-Rails part of has_image.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Test the Rails part of has_image.'
Rake::TestTask.new(:test_rails) do |t|
  t.libs << 'lib'
  t.libs << 'test_rails'
  t.pattern = 'test_rails/**/*_test.rb'
  t.verbose = true
end

desc "Run rcov"
task :rcov do
  rm_f "coverage"
  rm_f "coverage.data"
  if PLATFORM =~ /darwin/
    exclude = '--exclude "gems"'
  else
    exclude = '--exclude "rubygems"'
  end
  rcov = "rcov --rails -Ilib:test --sort coverage --text-report #{exclude} --no-validator-links"
  cmd = "#{rcov} #{Dir["test/**/*.rb"].join(" ")}"
  sh cmd
end

desc 'Generate documentation for has_image.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'HasImage'
  rdoc.options << '--line-numbers' << '--inline-source' << '-c UTF-8'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('FAQ')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
